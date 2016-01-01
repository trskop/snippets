{-# LANGUAGE TupleSections #-}
{-# LANGUAGE NoImplicitPrelude #-}
module DiagramDrawingArea
    ( createDiagramDrawingArea
    , handleDiagramDrawing
    )
  where

import Prelude (fromIntegral)

import Control.Monad (Monad((>>=), return))
import Data.Bool (Bool(True))
import Data.Function ((.))
import Data.Tuple (uncurry)
import System.IO (IO)

import Diagrams.Backend.Gtk (renderToGtk, toGtkCoords)
import Diagrams.Backend.Cairo (Cairo)
import Diagrams.Prelude
import Graphics.UI.Gtk


createDiagramDrawingArea
    :: (Monoid m, Semigroup m)
    => IO (QDiagram Cairo (V Cairo) (N Cairo) m)
    -- ^ Action that returns diagram that can be then rendered. Reason for
    -- using action is that we may need to be able to retrieve parameters of
    -- that diagram from other GTK widgets.
    -> IO (DrawingArea, ConnectId DrawingArea)
createDiagramDrawingArea getDiagram = do
    drawArea <- drawingAreaNew
    (drawArea,) <$> handleDiagramDrawing drawArea getDiagram

handleDiagramDrawing
    :: (Monoid m, Semigroup m)
    => DrawingArea
    -> IO (QDiagram Cairo (V Cairo) (N Cairo) m)
    -> IO (ConnectId DrawingArea)
handleDiagramDrawing drawArea getDiagram = drawArea `onExpose` \_event -> do
    dia <- getDiagram >>= scaleToWidget drawArea

    -- DrawingArea is not something that can be actually drawn in to. That
    -- would be DrawWindow, which we need to retrieve first, and only then
    -- render diagram in to that instead.
    widgetGetDrawWindow drawArea >>= (`renderToGtk` dia)

    -- Returning True indicates that handler successfully redrawn the wohole
    -- area. False indicates that other handlers in the chain should be
    -- invoked.
    return True
  where
    scaleToWidget w dia =
        toGtkCoords . scaleTo . widgetSizeToSizeSpec <$> widgetGetSize w
        -- The 'toGtkCoords' function performs two tasks.  It centers the
        -- diagram in the DrawWindow, and reflects it about the Y-axis.  The
        -- Y-axis reflection is due to an orientation mismatch between Cairo
        -- and diagrams.
      where
        -- Drawing to GTK requires that we manually specify the size and
        -- positioning, however we can use 'requiredScaling' to calculate the
        -- necessary rescaling for a full-scale image.
        scaleTo sizeSpec = transform (requiredScaling sizeSpec (size dia)) dia
        widgetSizeToSizeSpec = uncurry dims2D . castSize

        -- Window size is in pixels and has type (Int, Int), but we need it as
        -- (Double, Double), which is requirement of Cairo backend, before we
        -- can create SizeSpec.
        castSize = bimap fromIntegral fromIntegral

