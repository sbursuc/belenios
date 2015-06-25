(**************************************************************************)
(*                                BELENIOS                                *)
(*                                                                        *)
(*  Copyright © 2012-2014 Inria                                           *)
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

open Web_signatures

val home : featured:(module WEB_ELECTION) list -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val admin : elections:(module WEB_ELECTION) list -> setup_elections:(Uuidm.t list) -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val new_election : unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val new_election_failure : [ `Exists | `Exception of exn ] -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val generic_page : title:string -> string -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val election_setup : Uuidm.t -> Web_common.setup_election -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val election_setup_voters : Uuidm.t -> Web_common.setup_election -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val election_setup_questions : Uuidm.t -> Web_common.setup_election -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val election_setup_credentials : string -> string -> Web_common.setup_election -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val election_setup_trustee : string -> string -> Web_common.setup_election -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val election_home : (module WEB_ELECTION) -> Web_persist.election_state -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val election_admin : (module WEB_ELECTION) -> is_featured:bool -> Web_persist.election_state -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val update_credential : (module WEB_ELECTION) -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val cast_raw : (module WEB_ELECTION) -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val cast_confirmation : (module WEB_ELECTION) -> string -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val cast_confirmed : (module WEB_ELECTION) -> result:[< `Error of Web_common.error | `Valid of string ] -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val pretty_ballots : (module WEB_ELECTION) -> string list -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val tally_trustees : (module WEB_ELECTION) -> int -> unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val already_logged_in :
  unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val login_choose :
  string list ->
  (string -> (unit, unit, [< Eliom_service.get_service_kind ],
             [< Eliom_service.suff ], 'a, unit,
             [< Eliom_service.registrable ],
             [< Eliom_service.non_ocaml_service ])
            Eliom_service.service) ->
  unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t

val login_dummy : unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
val login_password : unit -> [> `Html ] Eliom_content.Html5.F.elt Lwt.t
