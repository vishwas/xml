#!/bin/bash -e

# allow a CABAL env var to override
CABAL=${CABAL:-cabal}

# install testing dependencies
$CABAL install HUnit QuickCheck hspec

source package-list.sh

# install each sub-respository
for pkg in "${pkgs[@]}"; do
  echo "Installing $pkg..."

  (
    cd "./$pkg"

    if ! $CABAL configure --enable-tests --ghc-options="-Wall -Werror"; then
      $CABAL install --only-dependencies
      $CABAL configure --enable-tests --ghc-options="-Wall -Werror"
    fi

    $CABAL build
    $CABAL test
    $CABAL check
    $CABAL haddock --executables
    ./Setup.lhs install
  )
done
