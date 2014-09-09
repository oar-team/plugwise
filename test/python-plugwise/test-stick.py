#!/usr/bin/env python

from plugwise import *

from serial.serialutil import SerialException

logs = {}
class Machine:
    """A simple class to describe a machine"""
    plugs = {}
    name = ""
    def __init__(self,name):
        self.name = name
        self.plugs = {}
    def print_name(self):
        print self.name
    def add_plug(self, name, mac, stick):
        self.plugs[name] = Circle("000D6F0000" + mac, stick);
    def get_logs(self):
        for k, v in self.plugs.iteritems():
            last_log = v.get_info()['last_logaddr']
            for i in range(last_log + 1):
                for dt, watt_hours in v.get_power_usage_history(i):
                    if not dt is None:
                        date = dt.strftime("%Y.%m.%d.%H")
                        if date not in logs:
                            logs[date] = {}
                        if self.name not in logs[date]:
                            logs[date][self.name] = {}
                        logs[date][self.name][k] = watt_hours

    def print_plugs_info(self):
        print self.name,
        for k, v in self.plugs.iteritems():
            print k,":", v.get_info(),
        print

    def print_logs(self,date):
        if date in logs:
            for k in sorted(self.plugs.keys()):
                if self.name not in logs[date]:
                    print 0.0,
                else:
                    if k not in logs[date][self.name]:
                        print 0.0,
                    else:
                        print logs[date][self.name][k],
        
    def print_logs_headers(self):
        for k in sorted(self.plugs.keys()):
            print self.name + "." + k,

print("Create stick...")
try:
    device = Stick("/dev/ttyUSB0", 30)
except (TimeoutException, SerialException) as reason:
    print("Error: %s (stick)" % (reason,))

print("Create machine and plugs...")
try:
    genepi = Machine("genepi")
    genepi.add_plug("pdu1", "76B48E", device)
except (TimeoutException, SerialException) as reason:
    print("Error: %s (add plug)" % (reason,))

try:
    genepi.print_plugs_info()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get info)" % (reason,))

try:
    genepi.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs genepi)" % (reason,))
