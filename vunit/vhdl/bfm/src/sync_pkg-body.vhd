-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

context work.vunit_context;
use work.queue_pkg.all;
context work.com_context;

package body sync_pkg is
  procedure wait_for_idle(signal net : inout network_t;
                          handle : sync_handle_t) is
    variable msg, reply_msg : msg_t;
  begin
    msg := create;
    push_msg_type(msg, wait_for_idle_msg);
    send(net, handle, msg);
    receive_reply(net, msg, reply_msg);
    delete(reply_msg);
  end;

  procedure wait_for_time(signal net : inout network_t;
                          handle : sync_handle_t;
                          delay : delay_length) is
    variable msg : msg_t;
  begin
    msg := create;
    push_msg_type(msg, wait_for_time_msg);
    push_time(msg, delay);
    send(net, handle, msg);
  end;

  procedure handle_sync_message(signal net : inout network_t;
                                variable msg_type : inout msg_type_t;
                                variable msg : inout msg_t) is
    variable reply_msg : msg_t;
    variable delay : delay_length;
  begin
    if msg_type = wait_for_idle_msg then
      handle_message(msg_type);
      reply_msg := create;
      reply(net, msg, reply_msg);

    elsif msg_type = wait_for_time_msg then
      handle_message(msg_type);
      delay := pop_time(msg);
      wait for delay;
    end if;
  end;

end package body;
