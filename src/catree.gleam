import argv
import catree/paths
import catree/renderer
import catree/target_finder
import gleam/list
import simplifile

// plan
//
// ✅ input_paths -> target_file_paths -> print
//
// ## ignore
// - toml で読み込む
pub fn main() -> Nil {
  let assert Ok(cwd) = simplifile.current_directory()

  let target_file_paths =
    argv.load().arguments
    |> paths.convert_to_absolute_paths(cwd)
    |> target_finder.get_target_file_paths(target_finder.GetTargetFilePathsDeps(
      target_finder.read_directory,
      target_finder.is_file,
    ))

  list.each(target_file_paths, fn(path) {
    renderer.print_file(
      path,
      renderer.PrintFileDeps(renderer.read_file, renderer.read_extension),
    )
  })

  Nil
}
