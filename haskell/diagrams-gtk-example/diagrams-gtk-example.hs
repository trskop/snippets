{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
module Main (main)
  where

import Diagrams.Backend.Cairo (Cairo)
import Diagrams.Prelude
import Graphics.UI.Gtk

import DiagramDrawingArea (createDiagramDrawingArea)


-- {{{ Hilbert curve ----------------------------------------------------------
--
-- http://projects.haskell.org/diagrams/gallery/Hilbert.html

hilbertExample :: Int -> Diagram Cairo
hilbertExample = frame 1 . lw medium . lc darkred . strokeT . hilbert
  where
    hilbert 0 = mempty
    hilbert n =
        hilbert' (n-1) # reflectY <> vrule 1
        <> hilbert  (n-1) <> hrule 1
        <> hilbert  (n-1) <> vrule (-1)
        <> hilbert' (n-1) # reflectX
      where
        hilbert' m = hilbert m # rotateBy (1/4)

-- }}} Hilbert curve ----------------------------------------------------------

-- {{{ Tournament -------------------------------------------------------------
--
-- http://projects.haskell.org/diagrams/doc/quickstart.html#a-worked-example

node :: Int -> Diagram Cairo
node n =
    text (show n) # fontSizeL 0.2 # fc white
    <> circle 0.2 # fc green # named n

arrowOpts :: ArrowOpts (N Cairo)
arrowOpts = with
    & gaps       .~ small
    & headLength .~ local 0.15

tournament :: Int -> Diagram Cairo
tournament n = nodes # connectWithArrows
  where
    nodes = atPoints (trailVertices $ regPoly n 1) (map node [1 .. n])
    connectWithArrows = applyAll
        [connectOutside' arrowOpts j k | j <- [1 .. n - 1], k <- [j + 1 .. n]]

-- }}} Tournament -------------------------------------------------------------

-- {{{ Pentaflake -------------------------------------------------------------
--
-- http://projects.haskell.org/diagrams/gallery/Pentaflake.html

grad :: Texture (N Cairo)
grad = defaultRG
    & _RG . rGradStops .~ mkStops [(blue,0,1), (crimson,1,1)]
    & _RG . rGradRadius1 .~ 50

pentaflake' :: Int -> Diagram Cairo
pentaflake' 0 = regPoly 5 1 # lw none
pentaflake' n = appends pCenter (zip vs (repeat (rotateBy (1/2) pOutside)))
  where
    vs = iterateN 5 (rotateBy (1/5)) . (if odd n then negated else id) $ unitY
    pCenter  = pentaflake' (n-1)
    pOutside = pCenter # opacity (1.7 / fromIntegral n)

pentaflake :: Int -> Diagram Cairo
pentaflake n = pentaflake' n # fillTexture grad # bgFrame 4 silver

-- }}} Pentaflake -------------------------------------------------------------

withWindow :: (Window -> IO a) -> IO a
withWindow f = do
    win <- windowNew

--  Tournament example would fail for value 1, since it is not possible to
--  create arrow between two different nodes.
--  depthWidget <- spinButtonNewWithRange 2 10 1
    depthWidget <- spinButtonNewWithRange 1 10 1

--  iterationWidget <- spinButtonNewWithRange 1 10 1

    (drawArea, _) <- createDiagramDrawingArea $
--      let dia = pentaflake
--      let dia = tournament
        let dia = hilbertExample
        in dia <$> spinButtonGetValueAsInt depthWidget

    -- When the spinButton changes, redraw the window.
    _ <- depthWidget `onValueSpinned` (widgetQueueDraw drawArea)

    vbox <- vBoxNew False 0
    boxPackStart vbox depthWidget PackNatural 0
--  boxPackStart vbox iterationWidget PackNatural 0

    hbox <- hBoxNew False 0
    boxPackStart hbox vbox PackNatural 0
    boxPackStart hbox drawArea PackGrow 0
    containerAdd win hbox

    f win

main :: IO ()
main = do
    _args <- initGUI
    withWindow $ \win -> do
        widgetShowAll win
        _ <- onDestroy win mainQuit
        -- Represent the desired width and height of the main window.
        _ <- onSizeRequest win $ return (Requisition 200 200)
        return ()
    mainGUI
