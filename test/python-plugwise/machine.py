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

try:
    device = Stick("/dev/ttyUSB0", 30)
except (TimeoutException, SerialException) as reason:
    print("Error: %s (stick)" % (reason,))

try:
    genepi = Machine("genepi")
    genepi.add_plug("pdu1", "76B48E", device)
    genepi.add_plug("pdu2", "76BF8F", device)
    genepi.add_plug("pdu3", "769F4D", device)
    genepi.add_plug("pdu4", "769FA0", device)
    genepi.add_plug("pdu5", "76AFC9", device)
    genepi.add_plug("wattmetre", "76D33E", device)
    edel_servers = Machine("edel-servers")
    edel_servers.add_plug("pdu1", "768EBB", device)
    edel_servers.add_plug("pdu2", "7310D0", device)
    edel_swib = Machine("edel-swib")
    edel_swib.add_plug("pdu", "7291CD", device)
    edel_chassis4 = Machine("edel-chassis4")
    edel_chassis4.add_plug("power1", "728B52", device)
    edel_chassis4.add_plug("power2", "7697C4", device)
    edel_chassis4.add_plug("power3", "76C6D1", device)
    edel_chassis4.add_plug("power4", "7313B7", device)
    adonis = Machine("adonis")
    adonis.add_plug("pdu1", "76A78A", device)
    adonis.add_plug("pdu2", "7313A4", device)
    adonis.add_plug("pdu3", "769A36", device)
    adonis.add_plug("pdu4", "76B4E3", device)
except (TimeoutException, SerialException) as reason:
    print("Error: %s (add plug)" % (reason,))

#try:
#    genepi.print_plugs_info()
#    edel_servers.print_plugs_info()
#    edel_swib.print_plugs_info()
#    edel_chassis4.print_plugs_info()
#    adonis.print_plugs_info()
#except (TimeoutException, SerialException) as reason:
#    print("Error: %s (get info)" % (reason,))

try:
    genepi.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs genepi)" % (reason,))
try:
    edel_servers.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs edel_servers)" % (reason,))
try:
    edel_swib.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs edel-swib)" % (reason,))
try:
    edel_chassis4.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs edel-chassis4)" % (reason,))
try:
    adonis.get_logs()
except (TimeoutException, SerialException) as reason:
    print("Error: %s (get logs adonis)" % (reason,))

print "date",
genepi.print_logs_headers()
edel_servers.print_logs_headers()
edel_swib.print_logs_headers()
edel_chassis4.print_logs_headers()
adonis.print_logs_headers()
print
for d in sorted(logs.keys()):
    print d,
    genepi.print_logs(d)
    edel_servers.print_logs(d)
    edel_swib.print_logs(d)
    edel_chassis4.print_logs(d)
    adonis.print_logs(d)
    print
