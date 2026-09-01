#!/usr/bin/env python3
"""
UDP reachability test.

Sends a minimal STUN Binding Request to a few public STUN servers and
checks whether any reply comes back. This mimics the kind of outbound
UDP "hole punching" that Discord voice connections rely on, without
needing a real Discord voice session.

Run this INSIDE the same container/host where Lavalink runs (not your
local machine), via the hosting panel's console:

    python3 udp_test.py

Interpreting results:
  - If at least one server replies "OK" -> outbound UDP generally works
    on this host. The voice connect issue is likely something more
    specific (Discord's voice IP/port range, or a narrower firewall
    rule) rather than a blanket UDP block.
  - If ALL servers show "FAIL (no reply)" -> outbound UDP is very
    likely blocked or not routed at all by this host. This is the
    clearest possible confirmation that it's a host limitation, not
    something fixable in Lavalink's own config.
"""

import socket
import struct
import time

# (host, port) - well-known public STUN servers
STUN_SERVERS = [
    ("stun.l.google.com", 19302),
    ("stun1.l.google.com", 19302),
    ("stun.cloudflare.com", 3478),
]

def build_stun_binding_request():
    # STUN message type: Binding Request (0x0001), length 0, magic cookie,
    # and a random 12-byte transaction ID.
    msg_type = 0x0001
    msg_length = 0
    magic_cookie = 0x2112A442
    transaction_id = struct.pack(">III", 0x11111111, 0x22222222, 0x33333333)
    header = struct.pack(">HHI", msg_type, msg_length, magic_cookie) + transaction_id
    return header

def test_server(host, port, timeout=4.0):
    request = build_stun_binding_request()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(timeout)
    start = time.time()
    try:
        addr = socket.getaddrinfo(host, port, socket.AF_INET, socket.SOCK_DGRAM)[0][4]
        sock.sendto(request, addr)
        data, _ = sock.recvfrom(1024)
        elapsed = time.time() - start
        ok = len(data) >= 20 and data[0:2] == b"\x01\x01"  # Binding Success Response
        return ok, elapsed, None
    except socket.timeout:
        return False, timeout, "no reply (timeout)"
    except Exception as e:
        return False, time.time() - start, str(e)
    finally:
        sock.close()

def main():
    print("Testing outbound UDP reachability via STUN servers...\n")
    any_success = False
    for host, port in STUN_SERVERS:
        ok, elapsed, err = test_server(host, port)
        if ok:
            any_success = True
            print(f"✅ OK      {host}:{port}  (replied in {elapsed:.2f}s)")
        else:
            reason = err or "unexpected response"
            print(f"❌ FAIL    {host}:{port}  ({reason})")

    print()
    if any_success:
        print("RESULT: Outbound UDP generally works on this host.")
        print("The voice connect issue is likely more specific than a")
        print("blanket UDP block (e.g. Discord's voice IP/port range,")
        print("or a narrower firewall rule) rather than the host")
        print("blocking UDP outright.")
    else:
        print("RESULT: No UDP replies from ANY server.")
        print("This strongly suggests outbound UDP is blocked or not")
        print("routed at all by this host -- consistent with the voice")
        print("connect timeouts you're seeing with Lavalink.")

if __name__ == "__main__":
    main()
