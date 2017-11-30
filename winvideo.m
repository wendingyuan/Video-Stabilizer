
info = imaqhwinfo('winvideo', 1);
Format = info.SupportedFormats{end};
vid = videoinput('winvideo', 1, 'YUY2_160x120');
vidRes = get(vid, 'VideoResolution');
set(vid, 'ReturnedColorSpace', 'rgb');
triggerconfig(vid, 'manual');

t = timer;
t.Period = 0.05;
t.ExecutionMode = 'fixedRate';
set(t, 'TimerFcn', {@Timer_TimerFcn, vid});
set(t, 'StartFcn', {@Timer_StartFcn, vid});
set(t, 'StopFcn',  {@Timer_StopFcn, vid});

%%
figure_handle = figure('Name', 'Camera Demo',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'ToolBar', 'none',...
    'Tag', 'camera_demo',...
    'Units', 'pixels');
axes_camera= axes('Parent', figure_handle,...
    'Tag', 'image',...
    'Units', 'pixels',...
    'Position',[0 100 vidRes(1) vidRes(2)],...
    'Color', [0 0 0],...
    'XTick',[],...
    'YTick',[]);
button_startStop = uicontrol('Parent', figure_handle,...
    'Style', 'pushbutton',...
    'Units', 'pixels',...
    'String', 'Start',...
    'Position', [20 30 60 30],...
    'CallBack',{@startStop_callback, t});
button_close = uicontrol('Parent', figure_handle,...
    'Style', 'pushbutton',...
    'Units', 'pixels',...
    'String', 'Close',...
    'Position', [230 30 60 30],...
    'CallBack', {@close_callback, t});
%%

%--------------------------------------------------------------------------
% 开始停止按钮的callback函数
function startStop_callback(hObject,eventdata, varargin)
global start_flag
t = varargin{1};

if strcmp('Stop', get(hObject, 'String'))
    set(hObject, 'String', 'Start');
    start_flag = false;
    stop(t);
elseif strcmp('Start', get(hObject, 'String'))
    start_flag = true;
    set(hObject, 'String', 'Stop')
    start(t)
end
end
%--------------------------------------------------------------------------
% 关闭按钮的callback函数
function close_callback(hObject,eventdata, varargin)
global start_flag
start_flag = false;
t = varargin{1};
stop(t);
delete(t);
close;
end
%--------------------------------------------------------------------------
% 
function Timer_StartFcn(hOject, eventdata, varargin)
vid = varargin{1};
start(vid);
end
%--------------------------------------------------------------------------
% 
function Timer_TimerFcn(hObject, eventdata, varargin)
vid = varargin{1};
persistent count;
if isempty(count)
     count = 1;
else
     count = count + 1;
end
frame = getsnapshot(vid);
if count <= 100
    imwrite(frame,[sprintf('%04d',count), '.jpg'], 'jpg');
end
global start_flag
if start_flag == true
    imshow(frame);
end
end
%--------------------------------------------------------------------------
% 
function Timer_StopFcn(hOject, eventdata, varargin)
vid = varargin{1};
stop(vid);
end