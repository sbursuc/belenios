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

open Serializable_builtin_t
open Serializable_t

type acl =
  | Any
  | Restricted of (Auth_common.user -> bool Lwt.t)

type election_web = {
  params_fname : string;
  public_keys_fname : string;
  featured_p : bool;
  can_read : acl;
  can_vote : acl;
}

module type WEB_BALLOT_BOX = sig
  module Ballots : Signatures.MONADIC_MAP_RO
    with type 'a m = 'a Lwt.t
    and type elt = string
    and type key = string
  module Records : Signatures.MONADIC_MAP_RO
    with type 'a m = 'a Lwt.t
    and type elt = Serializable_builtin_t.datetime * string
    and type key = string

  val cast : string -> string * datetime -> string Lwt.t
  val inject_creds : Util.SSet.t -> unit Lwt.t
  val extract_creds : unit -> Util.SSet.t Lwt.t
  val update_cred : old:string -> new_:string -> unit Lwt.t
end

module type WEB_ELECTION_BUNDLE =
  Signatures.ELECTION_BUNDLE with type 'a E.m = 'a Lwt.t

module type WEB_BALLOT_BOX_BUNDLE = sig
  include WEB_ELECTION_BUNDLE
  module B : WEB_BALLOT_BOX
end

type 'a web_election = private {
  modules : (module WEB_BALLOT_BOX_BUNDLE with type elt = 'a);
  election : 'a Signatures.election;
  election_web : election_web;
}

val make_web_election :
  string ->
  Serializable_t.metadata option ->
  election_web ->
  Z.t web_election