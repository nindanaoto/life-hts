# trace generated using paraview version 5.7.0
#
# To ensure correct image size when batch processing, please search 
# for and uncomment the line `# renderView*.ViewSize = [*,*]`

#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'CSV Reader'
jcsv = CSVReader(FileName=['/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.0', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.1', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.2', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.3', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.4', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.5', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.6', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.7', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.8', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.9', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.10', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.11', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.12', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.13', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.14', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.15', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.16', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.17', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.18', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.19', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.20', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.21', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.22', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.23', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.24', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.25', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.26', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.27', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.28', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.29', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.30', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.31', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.32', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.33', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.34', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.35', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.36', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.37', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.38', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.39', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.40', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.41', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.42', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.43', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.44', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.45', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.46', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.47', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.48', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.49', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.50', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.51', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.52', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.53', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.54', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.55', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.56', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.57', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.58', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.59', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.60', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.61', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.62', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.63', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.64', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.65', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.66', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.67', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.68', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.69', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.70', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.71', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.72', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.73', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.74', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.75', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.76', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.77', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.78', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.79', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.80', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.81', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.82', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.83', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.84', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.85', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.86', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.87', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.88', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.89', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.90', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.91', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.92', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.93', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.94', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.95', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.96', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.97', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.98', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.99', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.100', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.101', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.102', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.103', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.104', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.105', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.106', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.107', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.108', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.109', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.110', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.111', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.112', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.113', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.114', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.115', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.116', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.117', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.118', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.119', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.120', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.121', '/media/nimda/ボリューム/MatsuoLab/life-hts/scripts/periodic3d/j.csv.122'])

# get animation scene
animationScene1 = GetAnimationScene()

# get the time-keeper
timeKeeper1 = GetTimeKeeper()

# update animation scene based on data timesteps
animationScene1.UpdateAnimationUsingDataTimeSteps()

# Create a new 'SpreadSheet View'
spreadSheetView1 = CreateView('SpreadSheetView')
spreadSheetView1.ColumnToSort = ''
spreadSheetView1.BlockSize = 1024
# uncomment following to set a specific view size
# spreadSheetView1.ViewSize = [400, 400]

# show data in view
jcsvDisplay = Show(jcsv, spreadSheetView1)

# get layout
layout1 = GetLayoutByName("Layout #1")

# add view to a layout so it's visible in UI
AssignViewToLayout(view=spreadSheetView1, layout=layout1, hint=0)

# create a new 'Table To Points'
tableToPoints1 = TableToPoints(Input=jcsv)
tableToPoints1.XColumn = 'time'
tableToPoints1.YColumn = 'time'
tableToPoints1.ZColumn = 'time'

# set active source
SetActiveSource(tableToPoints1)

# show data in view
tableToPoints1Display = Show(tableToPoints1, spreadSheetView1)

# Properties modified on tableToPoints1
tableToPoints1.XColumn = 'x coord 0'
tableToPoints1.YColumn = 'y coord 0'
tableToPoints1.ZColumn = 'z coord 0'

# show data in view
tableToPoints1Display = Show(tableToPoints1, spreadSheetView1)

# hide data in view
Hide(jcsv, spreadSheetView1)

# update the view to ensure updated data information
spreadSheetView1.Update()

# create a new 'Calculator'
calculator1 = Calculator(Input=tableToPoints1)
calculator1.Function = ''

# set active source
SetActiveSource(calculator1)

# show data in view
calculator1Display = Show(calculator1, spreadSheetView1)

# Properties modified on calculator1
calculator1.Function = '(iHat*x scalar)+(jHat*y scalar)+(kHat*z scalar)'

# show data in view
calculator1Display = Show(calculator1, spreadSheetView1)

# hide data in view
Hide(tableToPoints1, spreadSheetView1)

# update the view to ensure updated data information
spreadSheetView1.Update()

# create a new 'Calculator'
calculator2 = Calculator(Input=calculator1)
calculator2.Function = ''

# set active source
SetActiveSource(calculator2)

# show data in view
calculator2Display = Show(calculator2, spreadSheetView1)

# Properties modified on calculator2
calculator2.ResultArrayName = 'Result2'
calculator2.Function = '(iHat*x scalar)+(jHat*y scalar)+(kHat*z scalar)'

# show data in view
calculator2Display = Show(calculator2, spreadSheetView1)

# hide data in view
Hide(calculator1, spreadSheetView1)

# update the view to ensure updated data information
spreadSheetView1.Update()

# find view
renderView1 = FindViewOrCreate('RenderView1', viewtype='RenderView')
# uncomment following to set a specific view size
# renderView1.ViewSize = [1642, 1801]

# set active view
SetActiveView(renderView1)

# set active source
SetActiveSource(calculator2)

# create a new 'Glyph'
glyph1 = Glyph(Input=calculator2,
    GlyphType='Arrow')
glyph1.OrientationArray = ['POINTS', 'Result2']
glyph1.ScaleArray = ['POINTS', 'No scale array']
glyph1.ScaleFactor = 6.74e-05
glyph1.GlyphTransform = 'Transform2'

# set active source
SetActiveSource(glyph1)

# show data in view
glyph1Display = Show(glyph1, renderView1)

# trace defaults for the display properties.
glyph1Display.Representation = 'Surface'
glyph1Display.ColorArrayName = [None, '']
glyph1Display.OSPRayScaleArray = 'Result'
glyph1Display.OSPRayScaleFunction = 'PiecewiseFunction'
glyph1Display.SelectOrientationVectors = 'None'
glyph1Display.ScaleFactor = 6.916654238011689e-05
glyph1Display.SelectScaleArray = 'None'
glyph1Display.GlyphType = 'Arrow'
glyph1Display.GlyphTableIndexArray = 'None'
glyph1Display.GaussianRadius = 3.458327119005844e-06
glyph1Display.SetScaleArray = ['POINTS', 'Result']
glyph1Display.ScaleTransferFunction = 'PiecewiseFunction'
glyph1Display.OpacityArray = ['POINTS', 'Result']
glyph1Display.OpacityTransferFunction = 'PiecewiseFunction'
glyph1Display.DataAxesGrid = 'GridAxesRepresentation'
glyph1Display.PolarAxes = 'PolarAxesRepresentation'

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
glyph1Display.ScaleTransferFunction.Points = [-156566337.9501177, 0.0, 0.5, 0.0, 182565822.7216063, 1.0, 0.5, 0.0]

# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
glyph1Display.OpacityTransferFunction.Points = [-156566337.9501177, 0.0, 0.5, 0.0, 182565822.7216063, 1.0, 0.5, 0.0]

# hide data in view
Hide(calculator2, renderView1)

# set scalar coloring
ColorBy(glyph1Display, ('POINTS', 'Result', 'Magnitude'))

# rescale color and/or opacity maps used to include current data range
glyph1Display.RescaleTransferFunctionToDataRange(True, False)

# show color bar/color legend
glyph1Display.SetScalarBarVisibility(renderView1, True)

# get color transfer function/color map for 'Result'
resultLUT = GetColorTransferFunction('Result')

# get opacity transfer function/opacity map for 'Result'
resultPWF = GetOpacityTransferFunction('Result')

# Properties modified on glyph1
glyph1.OrientationArray = ['POINTS', 'Result']
glyph1.ScaleArray = ['POINTS', 'Result']
glyph1.ScaleFactor = 1e-13

# show data in view
glyph1Display = Show(glyph1, renderView1)

# reset view to fit data
renderView1.ResetCamera()

# show color bar/color legend
glyph1Display.SetScalarBarVisibility(renderView1, True)

# update the view to ensure updated data information
renderView1.Update()

animationScene1.Play()

#### saving camera placements for all active views

# current camera placement for renderView1
renderView1.CameraPosition = [-0.00015492812828862962, -0.0014306040515833407, 0.0018480422322849695]
renderView1.CameraFocalPoint = [2.7343048714099386e-08, -2.6918132789433357e-07, 0.0001957623267117015]
renderView1.CameraViewUp = [0.015172446273899902, 0.7552690242270569, 0.6552392676856106]
renderView1.CameraParallelScale = 0.0005702709201287946

#### uncomment the following to render all views
# RenderAllViews()
# alternatively, if you want to write images, you can use SaveScreenshot(...).