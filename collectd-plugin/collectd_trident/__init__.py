#!/usr/bin/python
#===============================================================================
# collectd-trident - a collectd python plugin to consume trident measurements
#
# (C) Copyright 2018 CERN. This software is distributed under the terms of the
# GNU General Public Licence version 3 (GPL Version 3), copied verbatim in the
# file "COPYING". In applying this licence, CERN does not waive the privileges
# and immunities granted to it by virtue of its status as an Intergovernmental
# Organization or submit itself to any jurisdiction.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#===============================================================================

import collectd
import re
import os
import locale
import time
import errno
import datetime
import dateutil.parser
import pytz

#
# Common function(s)
#

def linebyline_generator(fd):
  ''' Generator to read lines from fd
  '''

  buf = bytearray()
  enc = locale.getpreferredencoding(False)
  while True:
    try:
      chunk = os.read(fd, 8192)
    except OSError as e:
      if e.errno == errno.EAGAIN or e.errno == errno.EWOULDBLOCK:
        yield ""
        continue
      raise

    if not chunk:
      if buf:
        yield buf.decode(end)
      break

    buf.extend(chunk)

    while True:
      r = buf.find(b'\r')
      n = buf.find(b'\n')
      if r == -1 and n == -1:
        break
      if r == -1 or r > n:
        yield buf[:(n+1)].decode(enc)
        buf = buf[(n+1):]
      elif n == -1 or n > r:
        yield buf[:r].decode(enc) + '\n'
        if n == r+1:
          buf = buf[(r+2):]
        else:
          buf = buf[(r+1):]


#
# Trident class
#

class Trident:
  # class variables
  sock_pattern = re.compile(r"\bS([0-9]+)\b")
  cp_pattern = re.compile(r"\b([CP])([0-9]+)\b")
  epochdate = datetime.datetime(1970,1,1,0,0,0,tzinfo=pytz.UTC)

  def plugin_config_method(self,config):
    ''' Take configuration options
    '''

    for node in config.children:
      key = node.key.lower()
      val = node.values[0]
      if key == 'fifo':
        self.fifopath = val
      elif key == 'headings':
        self.headingspath = val
      elif key == 'interval':
        self.default_interval = int(val)


  def plugin_init_method(self):
    ''' Setup instance variables
    '''

    self.needheadings = True
    self.headings = ()
    self.fifofd = -1
    self.fifoitr = None
    self.lastts = None
    self.default_interval = 10
    self.headingspath = '/tmp/tridentheadings'
    self.fifopath = '/tmp/tridentfifo'


  @staticmethod
  def __headingFixedGroupSize(h):
    ''' the length of the values set that should be returned for
        the type associated to this heading
    '''
    gs = 1
    res = Trident.cp_pattern.search(h)
    if res:
      if res.group(1) == 'C':
        gs = 4
      elif res.group(1) == 'P':
        gs = 8
    return gs


  def __read_headings(self):
    ''' read headings file
    '''

    self.headings = ()
    with open(self.headingspath, 'rb') as f:
      hline = f.readline().strip('\n\r"; ')
      self.headings = hline.split(';')
    self.headings = tuple(map(lambda it: it.strip(' "\n\r'),self.headings))
    self.headings = tuple(filter(len, self.headings));


  @staticmethod
  def __heading_to_type(s):
    ''' convert heading to collectd variable type name
    '''

    for r in [ ' ', '(', ')', '\\' ]:
      s = s.replace(r,'_')
    return 'trident_' + s.lower()


  @staticmethod
  def __isTimestamp(header):
    ''' is a heading the timestamp column
    '''

    return header.lower() == "timestamp"


  def __groupValues(self, grouped, header, value):
    ''' group headings by socket number and values for channel or port number
    '''

    value = long(float(value))
    sockn = None
    validx = 0
    groupsize = Trident.__headingFixedGroupSize(header)

    res = Trident.sock_pattern.search(header)
    if res:
      sockn = int(res.group(1))
      header = Trident.sock_pattern.sub('',header).strip()
    res = Trident.cp_pattern.search(header)
    if res:
      validx = int(res.group(2))
      header = Trident.cp_pattern.sub('',header).strip()

    grpnum = int(validx / groupsize)
    validx = validx % groupsize
    a = [None] * groupsize

    if header in grouped:
      x = grouped[header]
      if sockn in x:
        xx = x[sockn]
        if grpnum in xx:
          a = xx[grpnum]
        else:
          xx[grpnum] = a
      else:
        x[sockn] = { grpnum: a }
    else:
      grouped[header] = { sockn: { grpnum: a } }
    assert(validx < len(a))
    a[validx] = value

  def __findStampAndInterval(self,val):
    ''' convert timestamp value to epoch and deduce interval represented
    '''

    interval = None
    timestamp = int((dateutil.parser.parse(val) - Trident.epochdate).total_seconds())
    if self.lastts:
      if timestamp - self.lastts <= 300:
        interval = timestamp - self.lastts
    return timestamp, interval


  def __process_one_line(self,rawvals):
    ''' process one line of values, correspoonding to a set of measurements collected together
    '''

    assert len(rawvals) == len(self.headings)
    timestamp = None
    interval = None
    grouped = {}
    for h,v in zip(self.headings, rawvals):
      if Trident.__isTimestamp(h):
        try:
          timestamp, interval = self.__findStampAndInterval(v)
          self.lastts = timestamp
          if not interval:
            interval = self.default_interval
        except:
          continue
      else:
        self.__groupValues(grouped,h,v)

    collectd_values = []
    for h in grouped:
      for sockn in grouped[h]:
        xx = grouped[h][sockn]
        for grpnum in xx:
          v = xx[grpnum]
          val = collectd.Values(type=Trident.__heading_to_type(h))
          val.type_instance = ''
          if sockn != None:
            val.type_instance += 'socket ' + str(sockn)
          if grpnum > 0:
            if len(val.type_instance)>0:
              val.type_instance += ' '
            val.type_instance += 'extended-set ' + str(grpnum+1)
          if timestamp != None:
            val.time = timestamp
          val.plugin = 'trident'
          if interval:
            val.interval = interval
          val.values = v
          collectd_values.append(val)
    return collectd_values


  def __iterate_lines_and_process(self,itr):
    ''' read headings files and then 
        process lines of values from the iterator until there are no more available
    '''

    while True:
      line=itr.next().strip('\n\r; ')
      if not line:
        break
      if self.needheadings:
        try:
          self.__read_headings()
          self.needheadings = False
        except IOError:
          raise StopIteration
      rawvals = line.split(';')
      rawvals = tuple(map(lambda it: it.strip(' "\n\r'),rawvals))
      rawvals = tuple(filter(len, rawvals));
      if len(rawvals) != len(self.headings):
        raise StopIteration
      collectd_values = self.__process_one_line(rawvals)
      for val in collectd_values:
        val.dispatch()

  def plugin_read_method(self):
    ''' open fifo and read from it
    '''

    if not self.fifoitr:
      try:
        fd = os.open(self.fifopath, os.O_RDONLY | os.O_NONBLOCK)
        if self.fifofd >= 0:
          os.close(self.fifofd)
        self.fifofd = fd
        self.needheadings = True
        self.fifoitr = linebyline_generator(fd)
      except IOError:
          pass

    if self.fifoitr:
      try:
        self.__iterate_lines_and_process(self.fifoitr)
      except StopIteration:
        self.fifoitr = None

  def plugin_shutdown_method(self):
    ''' shutdown: close fifo fd and discard associated iterator
    '''

    self.fifoitr = None
    if self.fifofd >= 0:
      os.close(self.fifofd)
    self.fifofd = -1

#
# Global scope
#
x = Trident()
def plugin_init():
  x.plugin_init_method()
def plugin_read():
  x.plugin_read_method()
def plugin_shutdown():
  x.plugin_shutdown_method()
def plugin_config(config):
  x.plugin_config_method(config)

if __name__ == "__main__":
  # test
  while True:
    print 'calling plugin_init()'
    plugin_init()
    for i in range(1,30):
      print 'starting loop calling read_method()'
      plugin_read()
      time.sleep(1)
    print 'shutting down for 2 seconds'
    plugin_shutdown()
    time.sleep(2)
else:
  # running inside collectd
  collectd.register_init(plugin_init)
  collectd.register_read(plugin_read)
  collectd.register_shutdown(plugin_shutdown)
  collectd.register_config(plugin_config)
