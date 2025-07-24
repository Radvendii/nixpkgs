{
  lib,
  stdenv,
  fetchNpmDeps,
  buildPackages,
  nodejs,
  cctools,
}@topLevelArgs:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    {
      name ? "${args.pname}-${args.version}",
      src ? null,
      srcs ? null,
      sourceRoot ? null,
      prePatch ? "",
      patches ? [ ],
      postPatch ? "",
      patchFlags ? [ ],
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      # The output hash of the dependencies for this project.
      # Can be calculated in advance with prefetch-npm-deps.
      npmDepsHash ? "",
      # Whether to force the usage of Git dependencies that have install scripts, but not a lockfile.
      # Use with care.
      forceGitDeps ? false,
      # Whether to force allow an empty dependency cache.
      # This can be enabled if there are truly no remote dependencies, but generally an empty cache indicates something is wrong.
      forceEmptyCache ? false,
      # Whether to make the cache writable prior to installing dependencies.
      # Don't set this unless npm tries to write to the cache directory, as it can slow down the build.
      makeCacheWritable ? false,
      # The script to run to build the project.
      npmBuildScript ? "build",
      # Flags to pass to all npm commands.
      npmFlags ? [ ],
      # Flags to pass to `npm ci`.
      npmInstallFlags ? [ ],
      # Flags to pass to `npm rebuild`.
      npmRebuildFlags ? [ ],
      # Flags to pass to `npm run ${npmBuildScript}`.
      npmBuildFlags ? [ ],
      # Flags to pass to `npm pack`.
      npmPackFlags ? [ ],
      # Flags to pass to `npm prune`.
      npmPruneFlags ? finalAttrs.npmInstallFlags,
      # Value for npm `--workspace` flag and directory in which the files to be installed are found.
      npmWorkspace ? null,
      nodejs ? topLevelArgs.nodejs,
      npmDeps ? fetchNpmDeps {
        inherit (finalAttrs)
          forceGitDeps
          forceEmptyCache
          src
          srcs
          sourceRoot
          prePatch
          patches
          postPatch
          patchFlags
          ;
        name = "${name}-npm-deps";
        hash = finalAttrs.npmDepsHash;
      },
      # Custom npmConfigHook
      npmConfigHook ? null,
      # Custom npmBuildHook
      npmBuildHook ? null,
      # Custom npmInstallHook
      npmInstallHook ? null,
      ...
    }@args:

    let
      # .override {} negates splicing, so we need to use buildPackages explicitly
      npmHooks = buildPackages.npmHooks.override {
        inherit nodejs;
      };
      inherit (finalAttrs)
        name
        src
        srcs
        sourceRoot
        prePatch
        patches
        postPatch
        patchFlags
        nativeBuildInputs
        buildInputs
        npmDepsHash
        forceGitDeps
        forceEmptyCache
        makeCacheWritable
        npmBuildScript
        npmFlags
        npmInstallFlags
        npmRebuildFlags
        npmBuildFlags
        npmPackFlags
        npmPruneFlags
        npmWorkspace
        nodejs
        npmDeps
        npmConfigHook
        npmBuildHook
        npmInstallHook
        ;
    in
    {
      inherit npmDeps npmBuildScript;

      nativeBuildInputs =
        nativeBuildInputs
        ++ [
          nodejs
          # Prefer passed hooks
          (if npmConfigHook != null then npmConfigHook else npmHooks.npmConfigHook)
          (if npmBuildHook != null then npmBuildHook else npmHooks.npmBuildHook)
          (if npmInstallHook != null then npmInstallHook else npmHooks.npmInstallHook)
          nodejs.python
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools ];
      buildInputs = buildInputs ++ [ nodejs ];

      strictDeps = true;

      # Stripping takes way too long with the amount of files required by a typical Node.js project.
      dontStrip = finalAttrs.dontStrip or true;

      env = {
        npm_config_arch =
          {
            "x86_64" = "x64";
            "aarch64" = "arm64";
          }
          .${stdenv.hostPlatform.parsed.cpu.name} or stdenv.hostPlatform.parsed.cpu.name;
        npm_config_platform = stdenv.hostPlatform.parsed.kernel.name;
      }
      // (finalAttrs.env or { });

      meta = (finalAttrs.meta or { }) // {
        platforms = finalAttrs.meta.platforms or finalAttrs.nodejs.meta.platforms;
      };
    };
}
