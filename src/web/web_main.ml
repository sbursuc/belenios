(**************************************************************************)
(*                                BELENIOS                                *)
(*                                                                        *)
(*  Copyright © 2012-2018 Inria                                           *)
(*                                                                        *)
(*  This program is free software: you can redistribute it and/or modify  *)
(*  it under the terms of the GNU Affero General Public License as        *)
(*  published by the Free Software Foundation, either version 3 of the    *)
(*  License, or (at your option) any later version, with the additional   *)
(*  exemption that compiling, linking, and/or using OpenSSL is allowed.   *)
(*                                                                        *)
(*  This program is distributed in the hope that it will be useful, but   *)
(*  WITHOUT ANY WARRANTY; without even the implied warranty of            *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *)
(*  Affero General Public License for more details.                       *)
(*                                                                        *)
(*  You should have received a copy of the GNU Affero General Public      *)
(*  License along with this program.  If not, see                         *)
(*  <http://www.gnu.org/licenses/>.                                       *)
(**************************************************************************)

open Lwt
open Serializable_builtin_t
open Web_serializable_j
open Web_common

(** Global initialization *)

(* FIXME: the following should be in configuration file... but
   <maxrequestbodysize> doesn't work *)
let () = Ocsigen_config.set_maxrequestbodysizeinmemory 128000

let () = CalendarLib.Time_Zone.(change Local)

(** Parse configuration from <eliom> *)

let spool_dir = ref None
let source_file = ref None
let auth_instances = ref []
let gdpr_uri = ref None
let default_group_file = ref None

let () =
  Eliom_config.get_config () |>
  let open Simplexmlparser in
  List.iter @@ function
  | PCData x ->
    Ocsigen_extensions.Configuration.ignore_blank_pcdata ~in_tag:"belenios" x
  | Element ("log", ["file", file], []) ->
    Lwt_main.run (open_security_log file)
  | Element ("source", ["file", file], []) ->
    source_file := Some file
  | Element ("default-group", ["file", file], []) ->
    default_group_file := Some file
  | Element ("maxmailsatonce", ["value", limit], []) ->
    Web_config.maxmailsatonce := int_of_string limit
  | Element ("uuid", ["length", length], []) ->
     let length = int_of_string length in
     if length >= min_uuid_length then
       Web_config.uuid_length := Some length
     else
       failwith "UUID length is too small"
  | Element ("contact", ["uri", uri], []) ->
    Web_config.contact_uri := Some uri
  | Element ("gdpr", ["uri", uri], []) ->
    gdpr_uri := Some uri
  | Element ("server", attrs, []) ->
     let set attr setter =
       match List.assoc_opt attr attrs with
       | Some mail ->
          if is_email mail then setter mail
          else Printf.ksprintf failwith "%s is not a valid e-mail address" mail
       | None -> ()
     in
     set "mail" (fun x -> Web_config.server_mail := x);
     set "return-path" (fun x -> Web_config.return_path := Some x);
  | Element ("spool", ["dir", dir], []) ->
    spool_dir := Some dir
  | Element ("warning", ["file", file], []) ->
     Web_config.warning_file := Some file
  | Element ("rewrite-prefix", ["src", src; "dst", dst], []) ->
    set_rewrite_prefix ~src ~dst
  | Element ("auth", ["name", auth_instance],
             [Element (auth_system, auth_config, [])]) ->
    let i = {auth_system; auth_instance; auth_config} in
    auth_instances := i :: !auth_instances
  | Element (tag, _, _) ->
    Printf.ksprintf failwith
      "invalid configuration for tag %s in belenios"
      tag

let () =
  match !gdpr_uri with
  | None -> failwith "You must provide a GDPR URI"
  | Some x -> Web_config.gdpr_uri := x

(** Parse configuration from other sources *)

let%lwt source_file =
  match !source_file with
  | Some f ->
    let%lwt b = file_exists f in
    if b then (
      return f
    ) else (
      Printf.ksprintf failwith "file %s does not exist" f
    )
  | None -> failwith "missing <source> in configuration"

let spool_dir =
  match !spool_dir with
  | Some d -> d
  | None -> failwith "missing <spool> in configuration"

let%lwt default_group =
  match !default_group_file with
  | None -> failwith "missing <default-group> in configuration"
  | Some x ->
     let%lwt x = Lwt_io.lines_of_file x |> Lwt_stream.to_list in
     match x with
     | [x] -> return x
     | _ -> failwith "invalid default group file"

(** Build up the site *)

let () = Web_config.source_file := source_file
let () = Web_config.spool_dir := spool_dir
let () = Web_config.default_group := default_group
let () = Web_config.site_auth_config := List.rev !auth_instances
