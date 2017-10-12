function varargout = KPFS(varargin)
global sim;
% KPFS MATLAB code for KPFS.fig
%      KPFS, by itself, creates a new KPFS or raises the existing
%      singleton*.
%
%      H = KPFS returns the handle to a new KPFS or the handle to
%      the existing singleton*.
%
%      KPFS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KPFS.M with the given input arguments.
%
%      KPFS('Property','Value',...) creates a new KPFS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KPFS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KPFS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KPFS

% Last Modified by GUIDE v2.5 09-Oct-2017 14:34:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KPFS_OpeningFcn, ...
                   'gui_OutputFcn',  @KPFS_OutputFcn, ...
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

% --- Executes just before KPFS is made visible.
function KPFS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KPFS (see VARARGIN)

% Choose default command line output for KPFS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using KPFS.
axes(handles.axes1);
axis([1 200 1 200]);

% UIWAIT makes KPFS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = KPFS_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)



% --- Executes on button press in goToGoal.
function goToGoal_Callback(hObject, eventdata, handles)

global emergencyBrakesOn;
emergencyBrakesOn = 0;
follower = nhrInit(10,2.5);
leader = nhrInit(200,2.5);
leaderEstimate = nhrInit(100,2.5);
followingDistance = 100; %TODO: change according to speed
cla(handles.axes1);
cla(handles.axes2);
canvasInit(handles.axes1);

%Plot initial config
followerPlot = nhrPlot(follower, 'r');
leaderPlot = nhrPlot(leader, 'g');

%set one goal
goal = nhrSetGoals(1);
%plot goal
%nhrPlotGoals(goal);
%run simulation
%Init Control Parameters
dt = 0.01;
t = 0;
xRealFollower= [];
xRealLeader = [];

error(1) = sqrt((leader.x - follower.x)^2 +  (leader.y - follower.y)^2);
leaderDesiredVel = 26;
velIntegral = 0;
prevVelError = 0;
cruiseIntegral = 0;
prevCruiseError = 0;
leaderCruiseIntegral = 0;
prevLeaderCruiseError = 0;
%sensor noises
gpsVar = 1; % 1 meter
encoderVar = 0.01;
lidarVar  = 0.0009; % 3 cm
radarVar  = 0.25;
%input noise
varInput = 0.01;
varLeaderInput = 6.76; % 2.67^2
%initial state
u = [0;0];
uLeader(:,1) = [0;0];
xRealFollower(:,1) = [10;2.5;0;0];
xRealLeader(:,1) = [200;2.5;0;0];
x(:,1) = xRealFollower;
xLeader(:,1) = [200;2.5;0;0;0;0];

F = [1  0  dt 0 ;
     0  1  0  dt;
     0  0  1  0 ;
     0  0  0  1];
leaderF = [1  0  dt 0  (dt^2)/2 0;
           0  1  0  dt 0        (dt^2)/2;
           0  0  1  0  dt       0;
           0  0  0  1  0        dt;
           0  0  0  0  1        0
           0  0  0  0  0        1];

B = [0.5*(dt^2) 0 ;  
    0           0.5*(dt^2);
    dt          0 ;
    0           dt];

P = [10 0  0  0 ;
     0  10  0  0 ;
     0  0  1  0 ;
     0  0  0  1];
leaderP = [1 0  0  0 0 0;
           0  1 0  0 0 0;
           0  0  10  0 0 0;
           0  0  0  10 0 0;
           0  0  0  0 10 0;
           0  0  0  0 0 10];

H = [1  0  0  0 ;
     0  1  0  0 ;
     1  0  0  0 ;
     0  1  0  0];
leaderH =  [1  0  0  0 0 0;
            0  1  0  0 0 0;
            1  0  0  0 0 0;
            0  1  0  0 0 0];
Q = [0  0  0         0 ;
     0  0  0         0 ;
     0  0  varInput  0 ;
     0  0  0         varInput];
 
leaderQ = [0  0  0  0  0 0;
           0  0  0  0  0 0;
           0  0  0  0  0 0;
           0  0  0  0  0 0;
           0  0  0  0  varLeaderInput 0;
           0  0  0  0   0 varLeaderInput];
 
R = [gpsVar  0  0     0 ;
     0  gpsVar  0     0 ;
     0  0  encoderVar     0 ;
     0  0     0   encoderVar];
 
leaderR =[lidarVar  0 0   0     ;
          0  lidarVar 0   0     ;
          0  0  radarVar  0     ;
          0  0     0   radarVar ];
index = 2;
v(1) = 0;
while(true)
    %calculate the actual state based on previous input.
     xRealFollower(:,index) = (F*xRealFollower(:,index-1) + B*u);
     xRealLeader(:,index) = (F*xRealLeader(:,index-1) + B*uLeader(:,index-1)); 
    % generate sensor mesaurements with noise for follower.
    Z(:,index) = [xRealFollower(1,index) + normrnd(0,sqrt(gpsVar));
                  xRealFollower(2,index) + normrnd(0,sqrt(gpsVar));
                  xRealFollower(1,index) + normrnd(0,sqrt(encoderVar));
                  xRealFollower(2,index) + normrnd(0,sqrt(encoderVar))
                 ];
    % generate sensor mesaurements with noise for leader. 
    leaderZ(:,index) = [xRealLeader(1,index) + normrnd(0,sqrt(lidarVar));
                  xRealLeader(2,index) + normrnd(0,sqrt(lidarVar));
                  xRealLeader(1,index) + normrnd(0,sqrt(radarVar));
                  xRealLeader(2,index) + normrnd(0,sqrt(radarVar))
                 ];
    % prediction for follower
    P1 = F*P*F' + Q;
    S  = H*P1*H' + R;
    % prediction for leader
    leaderP1 = leaderF*leaderP*leaderF' + leaderQ;
    leaderS  = leaderH*leaderP1*leaderH' + leaderR;
    % measurements update
    %kalman gain for follower
    K = P1*H'*inv(S);
    %kalman gain for leader
    leaderK = leaderP1*leaderH'*inv(leaderS);
    % state covariance update for follower
    P = P1 - K*H*P1;
    % state covariance update for leader
    leaderP = leaderP1 - leaderK*leaderH*leaderP1
    % state update for follower
    x(:,index) = F*x(:,index-1) + B*u +  K*(Z(:,index)-H*(F*x(:,index-1)+B*u)); 
    % state update for leader
    xLeader(:,index) = leaderF*xLeader(:,index-1)  +  leaderK*(leaderZ(:,index)-leaderH*(leaderF*xLeader(:,index-1))); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    followerEstimate.x = x(1,index);
    followerEstimate.y = x(2,index);
    followerEstimate.v = sqrt(x(3,index)^2 + x(4,index)^2);
    
    leaderEstimate.x = xLeader(1,index);
    leaderEstimate.y = xLeader(2,index);
    leaderEstimate.v = sqrt(xLeader(3,index)^2 + xLeader(4,index)^2);
    
    leader.x = xRealLeader(1,index);
    leader.y = xRealLeader(2,index);
    leader.v = sqrt(xRealLeader(3,index)^2 + xRealLeader(4,index)^2);
    v(index) = followerEstimate.v;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Leader Controller %
    if(emergencyBrakesOn == 1)
        if(leader.v > 1)
            uLeader(:,index)= [-9.8 ;0];
        else
            uLeader(:,index) = [0;0];
        end
    else
        % leader PID controller to do cruise control
        leaderCruiseError = leaderDesiredVel - leader.v;
        leaderCruiseIntegral = leaderCruiseIntegral + leaderCruiseError*dt;
        leaderCruiseDerivative = (leaderCruiseError - prevLeaderCruiseError)/dt;

        [leader, ux, uy] = nhrCruiseOneGoal(goal, leader, leaderCruiseError, leaderCruiseIntegral, leaderCruiseDerivative);
        % construct input vector with noise
        uLeader(:,index)= [ux ;
             uy;
        ];
    end
    prevLeaderCruiseError = leaderCruiseError;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Follower Controller %
    if(sqrt((leaderEstimate.x - followerEstimate.x)^2 +  (leaderEstimate.y - followerEstimate.y)^2) <= followingDistance )
    % Follow the leaders velocity
        cruiseError = leaderEstimate.v - followerEstimate.v;
        cruiseIntegral = cruiseIntegral + cruiseError*dt;
        cruiseDerivative = (cruiseError - prevCruiseError)/dt;
        
        [followerEstimate, ux, uy] = nhrCruiseOneGoal(leaderEstimate, followerEstimate, cruiseError, cruiseIntegral,cruiseDerivative);
        % construct input vector with noise
        u = [ux ;%+ normrnd(0,sqrt(varInput));
             0 %+ normrnd(0,sqrt(varInput))
        ];
        if(leaderEstimate.v < 1)
            u = [0;0];
        end
        prevCruiseError = cruiseError;
    else  
        % Maintain a following distance to the leader
        velError = error(index-1) - followingDistance;
        velIntegral = velIntegral + velError*dt;
        velDerivative = (velError - prevVelError)/dt;

        % calculate u using PID
        [followerEstimate, ux, uy] = nhrNavOneGoal(leaderEstimate, followerEstimate, velError,velIntegral,velDerivative);
        % construct input vector with noise
        u = [ux ;%+ normrnd(0,sqrt(varInput));
             0%uy %+ normrnd(0,sqrt(varInput))
        ];
        prevVelError = velError;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot follower position and velocity
    follower.x = xRealFollower(1,index);
    follower.y = xRealFollower(2,index);
    follower.theta =  atan2(xRealFollower(4,index),xRealFollower(3,index));
    follower.v = xRealFollower(3,index);
    axes(handles.axes1);
    followerPlot = nhrUpdateRobotPlot(follower, followerPlot, 'r');
    leaderPlot = nhrUpdateRobotPlot(leader, leaderPlot, 'g');
    %plot sensor data for follower
    plot(Z(1,index), Z(2,index), '.', 'Color', 'b');
    plot(Z(3,index), Z(4,index), '.', 'Color', 'g');
    % plot follower position estimate
    plot(x(1,index), x(2,index), '.', 'Color', 'y'); 
    % plot leader position estimate
    plot(leaderEstimate.x, leaderEstimate.y, '.', 'Color', 'y'); 
    axes(handles.axes2); %set the current axes to axes2
    ylabel('velocity (m/s)');
    xlabel('time (sec)');
    plot(t,follower.v,'.','color', 'g');
    hold on

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    error(index) = sqrt((leader.x - follower.x)^2 +  (leader.y - follower.y)^2);
    
    t = dt + t;
    index = index + 1;
    pause(dt);
end
hold off
axes(handles.axes1);
hold off
%plotting the speed of the follower and distance to the goal (estimated)
time = 0:dt:t+dt;
time = time(1:length(v));
figure, plot(time,v); xlabel('time (sec)'); ylabel('speed (m/s)'); title('estimated speed of the follower');
figure, plot(time,error); xlabel('time (sec)'); ylabel('Distance to goal (m)'); title('Estimated distance to goal over time');

% plotting the estimated x and y values of the follower
figure, plot(time,x(1,:)); xlabel('time (sec)'); ylabel('estimated x (m)'); title('estimated x position of the follower');
figure, plot(time,x(2,:)); xlabel('time (sec)'); ylabel('estimated y (m)'); title('estimated y position of the follower');

%plotting the estimated x and y position together with the sensory
%measurements and the actual values for comparison.
figure, plot(time,x(1,:),'b'); hold on;
plot(time,Z(1,:), 'r'); hold on;
plot(time,Z(3,:), 'g'); hold on; 
plot(time,xRealFollower(1,:), 'k'); xlabel('time (sec)'); ylabel('x position (m)'); hold on; 
legend('estimated x position', 'sensor 1','sensor 2', 'actual x');

figure, plot(time,x(2,:),'b'); hold on;
plot(time,Z(2,:), 'r'); hold on;
plot(time,Z(4,:), 'g'); hold on; 
plot(time,xRealFollower(2,:), 'k'); xlabel('time (sec)'); ylabel('y position (m)'); hold on; 
legend('estimated y position', 'sensor 1','sensor 2', 'actual y');


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global emergencyBrakesOn;
emergencyBrakesOn = 1;