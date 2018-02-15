
{-# language NamedFieldPuns #-}
{-# language TemplateHaskell #-}

module Data.Tree.AVL.Lookup where

import Control.Lens hiding (locus, Empty)

import Data.Tree.AVL.Internal
import Data.Tree.AVL.Proof
import Data.Tree.AVL.Zipper

lookup :: Hash h k v => k -> Map h k v -> ((Maybe v, Proof h k v), Map h k v)
lookup k tree0 = ((mv, proof), tree)
  where
    (mv, tree, proof) = runZipped (lookup' k) UpdateMode tree0

lookup' :: Hash h k v => k -> Zipped h k v (Maybe v)
lookup' k = do
    goto k
    tree <- use locus
    mark
    case () of
      ()
        | Just end <- tree^.terminal ->
            if end^.key == k
            then
                return (end^.value.to Just)
            else
                return Nothing

        | Just Vacuous <- tree^.vacuous ->
            return Nothing

        | otherwise ->
            error $ "lookup: `goto " ++ show k ++ "` ended in non-terminal node"
