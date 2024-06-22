open Riot
module Event = Event
module Command = Command
module App = App
module Program = Program

type config = {
  fps: int;
}

let make_config ?(fps = 60) () = {fps}

let default_config = make_config ()

let app = App.make

let run ?(fps = 60) ~initial_model app =
  let prog = Program.make ~app ~fps in
  Program.run prog initial_model;
  Logger.trace (fun f -> f "terminating")

let start ?(config = default_config) app ~initial_model =
  let module App = struct
    let start () =
      Logger.set_log_level None;
      let pid =
        spawn_link (fun () ->
            run ~fps:config.fps app ~initial_model;
            Logger.trace (fun f -> f "about to shutdown");
            shutdown ~status:0 ())
      in
      Ok pid
  end in
  Riot.start ~apps:[ (module Riot.Logger); (module App) ] ()
