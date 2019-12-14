function varargout = TablesMultiplication(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TablesMultiplication_OpeningFcn, ...
                   'gui_OutputFcn',  @TablesMultiplication_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before TablesMultiplication is made visible.
function TablesMultiplication_OpeningFcn(hObject, eventdata, h, varargin)
h.output = hObject;
guidata(hObject, h);

% --- Outputs from this function are returned to the command line.
function varargout = TablesMultiplication_OutputFcn(hObject, eventdata, h) 
% init graphical objects
%h.cm = [h.cm ; flipud(h.cm(1:end-1,:))];
circle = exp( - i .* linspace( -pi/2 ,2.*pi - pi/2, 1000) ).';
h.PlotCircles = plot(h.axes1,circle,'Color','w');
axis(h.axes1,'off'); axis(h.axes1,'equal');
set(h.axes1,'Nextplot','add','xlim',[-1 1],'ylim',[-1 1],'Color','k');
h.PlotLines = plot(h.axes1,NaN,NaN,'linewidth',1,'Color','w','ButtonDownFcn',@plotLines_Onclick);
h.Timer = timer('ExecutionMode','fixedRate','period',0.02,'TimerFcn',{@timerFcn,h.figure1});
% init variable structure
h.var = struct(...
    'x' , 807,   'x_min',  2, 'x_max', 2000, 'x_inc', 10 , ...
    'y' , 620,   'y_min',  2, 'y_max', 2000, 'y_inc', 10 , ...
    'dx',0.01,  'dx_min',-0.5, 'dx_max', 0.5, 'dx_inc', 0.01,...
    'dy',0.01,  'dy_min',-0.5, 'dy_max', 0.5, 'dy_inc', 0.01,...
    'delay', 0.005 , 'delay_min', 0.005 , 'delay_max',5, 'delay_inc', 0.005);
% update edit boxes
set( h.ed_y,'String', num2str( h.var.y,'%2.2f'))
set( h.ed_x,'String', num2str( h.var.x,'%2.2f'))
set(h.ed_dy,'String', num2str(h.var.dy,'%2.2f'))
set(h.ed_dx,'String', num2str(h.var.dx,'%2.2f'))
set(h.ed_delay,'String', num2str(h.var.delay,'%2.4f'))
% set the sliders invisible, may be used down the road
set([h.sl_delay h.sl_dx h.sl_dy] ,'Visible','off')
% save and run
varargout{1} = h.output;
guidata(hObject, h);
start(h.Timer)

function timerFcn(hobj,evt,fig)
h = guidata(fig);
% compute new variables
h.var.x = h.var.x + h.var.dx;
h.var.y = h.var.y + h.var.dy;
if  ( h.var.y > h.var.y_max) |  ( h.var.y < h.var.y_min) 
    h.var.dy = -h.var.dy;
    set(h.ed_dy,'String', num2str(h.var.dy,'%2.2f'))
end
if  ( h.var.x > h.var.x_max) |  ( h.var.x < h.var.x_min) 
    h.var.dx = -h.var.dx;
    set(h.ed_dx,'String', num2str(h.var.dx,'%2.2f'))
end
toplot = ComputeTable(h.var.x,h.var.y);
% display
set(h.PlotLines,'xdata',real(toplot), 'ydata', imag(toplot))
% update edit boxes
set(h.ed_y,'String', num2str(h.var.y,'%2.2f'))
set(h.ed_x,'String', num2str(h.var.x,'%2.2f'))
guidata(fig,h);
% update the plot color
col = getcolor(h,  mod(get(h.Timer,'TasksExecuted'),1000)/999 );
set([h.PlotCircles h.PlotLines], 'Color',col)

function toplot = ComputeTable(x,y)
% On représente la table de x modulo y en reliant chaque nombre
in = [1:(y-1)].';
cir = @(x) exp(-i .* x .* 2 .*pi + i.*pi/2);
toplot = ([cir(in/y) cir(mod(in*x , y) ./ y )  in.*NaN].');
toplot = toplot(:);

function update_graphics(h)
if strcmp(get(h.PbStart,'String'),'Stop') & strcmp( get(h.Timer,'Running'),'off')
    start(h.Timer);
else
    timerFcn(h.figure1,[],h.figure1);
end

function plotLines_Onclick(hobj,evt)
% c = uisetcolor;
% if length(c)==1, return, end
% set(hobj,'Color',c)
h = guidata(hobj);
colormapeditor(h.figure1)

function figure1_CloseRequestFcn(hObject, evt, h)
try
    stop(h.Timer);
    delete(h.Timer);
end
delete(hObject);

function pb_Callback(hobj, evt, h)
h = guidata(h.figure1);

h.var.y = str2double(get( h.ed_y,'String'));
h.var.x = str2double(get( h.ed_x,'String'));
h.var.dy = str2double(get(h.ed_dy,'String'));
h.var.dx = str2double(get(h.ed_dx,'String'));
h.var.delay = str2double(get(h.ed_delay,'String'));


switch get(hobj,'Tag')
    case 'pb_x_minus'
       h.var.x = h.var.x - h.var.x_inc;
       h.var.x = min(h.var.x , h.var.x_max);
       h.var.x = max(h.var.x , h.var.x_min);
    case 'pb_x_plus'
       h.var.x = h.var.x + h.var.x_inc;
       h.var.x = min(h.var.x , h.var.x_max);
       h.var.x = max(h.var.x , h.var.x_min);
    case 'pb_dx_minus'
        h.var.dx = h.var.dx - h.var.dx_inc;
        h.var.dx = min(h.var.dx , h.var.dx_max);
        h.var.dx = max(h.var.dx , h.var.dx_min);
    case 'pb_dx_plus'
        h.var.dx = h.var.dx + h.var.dx_inc;
        h.var.dx = min(h.var.dx , h.var.dx_max);
        h.var.dx = max(h.var.dx , h.var.dx_min);
    case 'pb_y_minus'
       h.var.y = h.var.y - h.var.y_inc;
       h.var.y = min(h.var.y , h.var.y_max);
       h.var.y = max(h.var.y , h.var.y_min);
    case 'pb_y_plus'
       h.var.y = h.var.y + h.var.y_inc;
       h.var.y = min(h.var.y , h.var.y_max);
       h.var.y = max(h.var.y , h.var.y_min);
    case 'pb_dy_minus'
        h.var.dy = h.var.dy - h.var.dy_inc;
        h.var.dy = min(h.var.dy , h.var.dy_max);
        h.var.dy = max(h.var.dy , h.var.dy_min);
        disp(h.var.dy)
    case 'pb_dy_plus'
        h.var.dy = h.var.dy + h.var.dy_inc;
        h.var.dy = min(h.var.dy , h.var.dy_max);
        h.var.dy = max(h.var.dy , h.var.dy_min);
    case 'pb_delay_minus'
        h.var.delay = h.var.delay - h.var.delay_inc;
        h.var.delay = min(h.var.delay , h.var.delay_max);
        h.var.delay = max(h.var.delay , h.var.delay_min);
        stop(h.Timer), set(h.Timer,'period',h.var.delay);
        if strcmp(get(h.PbStart,'String'),'Stop'), start(h.Timer); end
    case 'pb_delay_plus'
        h.var.delay = h.var.delay + h.var.delay_inc;
        h.var.delay = min(h.var.delay , h.var.delay_max);
        h.var.delay = max(h.var.delay , h.var.delay_min);
        stop(h.Timer), set(h.Timer,'period',h.var.delay);
        if strcmp(get(h.PbStart,'String'),'Stop'), start(h.Timer); end
end
set( h.ed_y,'String', num2str( h.var.y,'%2.2f'))
set( h.ed_x,'String', num2str( h.var.x,'%2.2f'))
set(h.ed_dy,'String', num2str(h.var.dy,'%2.2f'))
set(h.ed_dx,'String', num2str(h.var.dx,'%2.2f'))
set(h.ed_delay,'String', num2str(h.var.delay,'%2.4f'))
guidata(h.figure1,h);

update_graphics(h)

function slider_Callback(hObject, eventdata, h)

function ed_delay_Callback(hObject, eventdata, h)

function ed_y_Callback(hObject, eventdata, h)
y = str2double(get(hObject,'String'));
if isnan(y), return, end
stop(h.Timer); h = guidata(h.figure1);
h.var.y = y;
guidata(h.figure1,h);
update_graphics(h)

function ed_x_Callback(hObject, eventdata, h)
x = str2double(get(hObject,'String'));
if isnan(x), return, end
stop(h.Timer); h = guidata(h.figure1);
h.var.x = x;
guidata(h.figure1,h);
update_graphics(h)



function ed_dy_Callback(hObject, eventdata, h)

function ed_dx_Callback(hObject, eventdata, h)

function PbStart_Callback(hobj, eventdata, h)
switch get(hobj,'String')
    case 'Stop'
        stop(h.Timer)
        set(hobj,'String','Start')
    case 'Start'
        start(h.Timer)
        set(hobj,'String','Stop')
end

function col = getcolor(h,ind)
if 1
h.cm = colormap;
h.cm = [h.cm ; flipud(h.cm(1:end-1,:))];
guidata(h.figure1,h)
end
col = [];
ind = ind *(size(h.cm,1)-1)+1;
frac = ind-floor(ind);
col = h.cm(floor(ind),:).*(1-frac) + h.cm(ceil(ind),:).*frac;
