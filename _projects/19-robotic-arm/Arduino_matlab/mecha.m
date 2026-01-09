function mecha
% 3DOF Yaw-Pitch-Pitch digital twin with:
% - Enter arm lengths (L1,L2,L3) then Apply
% - Cartesian control with arrow keys (IK) + W/S for Z
% - Home (button or H key) + Arduino command "H\n"
% - Smooth sliders + serial streaming "A,t1,t2,t3\n"

%% ---------------- DEFAULTS ----------------
L1 = 60; L2 = 120; L3 = 120; % mm (editable from GUI)

jointLim = [ -180  180;
              -90   90;
             -180  180];

homeTheta = [0 20 90];  % your chosen "home pose" in degrees

defaultBaud = 115200;
sendHz = 30;
posStep = 5; % mm per key press (arrows/W/S)

%% ---------------- STATE ----------------
theta = homeTheta;
targetXYZ = fk_pos(theta, L1,L2,L3);
elbowSign = +1;
sendEnabled = false;

sp = [];
tSend = [];
lastSentTheta = [nan nan nan];

%% ---------------- UI ----------------
fig = uifigure('Name','3DOF Arm Digital Twin v2 (Lengths + Homing)', ...
    'Position',[100 100 1250 720], 'KeyPressFcn', @onKey);

gl = uigridlayout(fig,[1 2]);
gl.ColumnWidth = {'1x','2.2x'};

left = uipanel(gl,'Title','Controls');
left.Layout.Row = 1; left.Layout.Column = 1;
lg = uigridlayout(left,[22 2]);
lg.RowHeight = repmat({28},1,22);
lg.ColumnWidth = {'1x','1x'};

right = uipanel(gl,'Title','3D View');
right.Layout.Row = 1; right.Layout.Column = 2;
rg = uigridlayout(right,[1 1]);
ax = uiaxes(rg);
grid(ax,'on'); axis(ax,'equal');
xlabel(ax,'X (mm)'); ylabel(ax,'Y (mm)'); zlabel(ax,'Z (mm)');
view(ax,3);

% ---- Length inputs
uilabel(lg,'Text','L1 base height (mm)','FontWeight','bold');
L1Field = uieditfield(lg,'numeric','Value',L1);

uilabel(lg,'Text','L2 upper arm (mm)','FontWeight','bold');
L2Field = uieditfield(lg,'numeric','Value',L2);

uilabel(lg,'Text','L3 forearm (mm)','FontWeight','bold');
L3Field = uieditfield(lg,'numeric','Value',L3);

applyLenBtn = uibutton(lg,'Text','Apply Lengths','ButtonPushedFcn',@(~,~)applyLengths());

% ---- Mode
uilabel(lg,'Text','Control mode:','FontWeight','bold');
modeDrop = uidropdown(lg,'Items',{'Cartesian (IK)','Joint Angles'}, ...
    'Value','Cartesian (IK)','ValueChangedFcn',@(~,~)updateAll());

% ---- Joint sliders
uilabel(lg,'Text','\theta1 yaw (deg)');
s1 = uislider(lg,'Limits',jointLim(1,:), 'Value',theta(1));
s1.ValueChangingFcn = @(~,e)onJointChanging(1,e.Value);

uilabel(lg,'Text','\theta2 shoulder (deg)');
s2 = uislider(lg,'Limits',jointLim(2,:), 'Value',theta(2));
s2.ValueChangingFcn = @(~,e)onJointChanging(2,e.Value);

uilabel(lg,'Text','\theta3 elbow (deg)');
s3 = uislider(lg,'Limits',jointLim(3,:), 'Value',theta(3));
s3.ValueChangingFcn = @(~,e)onJointChanging(3,e.Value);

% ---- Target XYZ
uilabel(lg,'Text','Target X (mm)');
xField = uieditfield(lg,'numeric','Value',targetXYZ(1),'ValueChangedFcn',@(~,~ )onTargetEdited());

uilabel(lg,'Text','Target Y (mm)');
yField = uieditfield(lg,'numeric','Value',targetXYZ(2),'ValueChangedFcn',@(~,~ )onTargetEdited());

uilabel(lg,'Text','Target Z (mm)');
zField = uieditfield(lg,'numeric','Value',targetXYZ(3),'ValueChangedFcn',@(~,~ )onTargetEdited());

% ---- Key step size
uilabel(lg,'Text','Key step (mm)','FontWeight','bold');
stepField = uieditfield(lg,'numeric','Value',posStep,'ValueChangedFcn',@(~,~)setStep());

% ---- Elbow toggle + Home
uilabel(lg,'Text','Elbow config');
elbowBtn = uibutton(lg,'Text','Elbow: DOWN (+)', 'ButtonPushedFcn',@(~,~)toggleElbow());

homeBtn = uibutton(lg,'Text','HOME (H)','ButtonPushedFcn',@(~,~)doHome());

% ---- Serial controls
uilabel(lg,'Text','COM Port (e.g. COM5)','FontWeight','bold');
comField = uieditfield(lg,'text','Value','COM5');

uilabel(lg,'Text','Baud','FontWeight','bold');
baudField = uieditfield(lg,'numeric','Value',defaultBaud);

connectBtn = uibutton(lg,'Text','Connect Arduino','ButtonPushedFcn',@(~,~)connectArduino());
sendBtn = uibutton(lg,'Text','Send: OFF (Space)','ButtonPushedFcn',@(~,~)toggleSend());

% ---- Status
status = uilabel(lg,'Text','Status: Enter lengths then Apply','FontWeight','bold');

% ---- Plot objects
hold(ax,'on');
hLink = plot3(ax,nan,nan,nan,'LineWidth',4);
hJ = scatter3(ax,nan,nan,nan,80,'filled');
hEE = scatter3(ax,nan,nan,nan,120,'filled');
hTarget = scatter3(ax,nan,nan,nan,120,'filled');
hold(ax,'off');

% ---- Timer for streaming
tSend = timer('ExecutionMode','fixedRate','Period',1/sendHz,'TimerFcn',@(~,~)sendToArduino());
fig.CloseRequestFcn = @onClose;

updateAll();

%% ---------------- CALLBACKS ----------------
    function applyLengths()
        a = L1Field.Value; b = L2Field.Value; c = L3Field.Value;
        if any([a b c] <= 0)
            status.Text = 'Status: Lengths must be > 0';
            return;
        end
        L1 = a; L2 = b; L3 = c;
        % Recompute target from current theta (so it stays consistent)
        targetXYZ = fk_pos(theta, L1,L2,L3);
        xField.Value = targetXYZ(1); yField.Value = targetXYZ(2); zField.Value = targetXYZ(3);
        status.Text = sprintf('Status: Lengths applied (L1=%.1f, L2=%.1f, L3=%.1f)',L1,L2,L3);
        updateAll();
    end

    function setStep()
        if stepField.Value > 0
            posStep = stepField.Value;
        end
    end

    function onJointChanging(idx,val)
        theta(idx) = val;
        theta = clampTheta(theta, jointLim);
        s1.Value = theta(1); s2.Value = theta(2); s3.Value = theta(3);
        targetXYZ = fk_pos(theta, L1,L2,L3);
        xField.Value = targetXYZ(1); yField.Value = targetXYZ(2); zField.Value = targetXYZ(3);
        updatePlot();
    end

    function onTargetEdited()
        targetXYZ = [xField.Value, yField.Value, zField.Value];
        if strcmp(modeDrop.Value,'Cartesian (IK)')
            th = ik_solve(targetXYZ, L1,L2,L3, elbowSign);
            if any(isnan(th))
                status.Text = 'Status: Target unreachable';
            else
                theta = clampTheta(th, jointLim);
                s1.Value = theta(1); s2.Value = theta(2); s3.Value = theta(3);
                status.Text = 'Status: IK solved';
            end
        end
        updatePlot();
    end

    function toggleElbow()
        elbowSign = -elbowSign;
        if elbowSign>0, elbowBtn.Text='Elbow: DOWN (+)';
        else, elbowBtn.Text='Elbow: UP (-)'; end
        updateAll();
    end

    function doHome()
        theta = homeTheta;
        theta = clampTheta(theta, jointLim);
        s1.Value = theta(1); s2.Value = theta(2); s3.Value = theta(3);
        targetXYZ = fk_pos(theta,L1,L2,L3);
        xField.Value = targetXYZ(1); yField.Value = targetXYZ(2); zField.Value = targetXYZ(3);
        status.Text = 'Status: HOME pose applied';

        % Tell Arduino to home (optional)
        if ~isempty(sp) && isvalid(sp)
            try
                write(sp, "H\n", "string");
            catch
                % ignore
            end
        end
        updatePlot();
    end

    function toggleSend()
        sendEnabled = ~sendEnabled;
        if sendEnabled
            sendBtn.Text = 'Send: ON (Space)';
            status.Text = 'Status: Streaming enabled';
        else
            sendBtn.Text = 'Send: OFF (Space)';
            status.Text = 'Status: Streaming disabled';
        end
    end

    function connectArduino()
        try
            if ~isempty(sp), clear sp; sp=[]; end
            sp = serialport(strtrim(comField.Value), baudField.Value);
            configureTerminator(sp,"LF");
            flush(sp);
            status.Text = 'Status: Arduino connected';
            if strcmp(tSend.Running,'off'), start(tSend); end
        catch ME
            status.Text = ['Status: Serial error - ' ME.message];
            sp = [];
        end
    end

    function onKey(~,evt)
        k = lower(evt.Key);

        if strcmp(k,'space'), toggleSend(); return; end
        if strcmp(k,'h'), doHome(); return; end
        if strcmp(k,'e'), toggleElbow(); return; end

        if strcmp(modeDrop.Value,'Cartesian (IK)')
            p = targetXYZ;
            switch k
                case 'rightarrow', p(1) = p(1) + posStep;
                case 'leftarrow',  p(1) = p(1) - posStep;
                case 'uparrow',    p(2) = p(2) + posStep;
                case 'downarrow',  p(2) = p(2) - posStep;
                case 'w',          p(3) = p(3) + posStep;
                case 's',          p(3) = p(3) - posStep;
                otherwise, return;
            end
            targetXYZ = p;
            xField.Value=p(1); yField.Value=p(2); zField.Value=p(3);

            th = ik_solve(p,L1,L2,L3, elbowSign);
            if any(isnan(th))
                status.Text = 'Status: Target unreachable';
            else
                theta = clampTheta(th, jointLim);
                s1.Value=theta(1); s2.Value=theta(2); s3.Value=theta(3);
                status.Text = 'Status: IK solved (keys)';
            end
            updatePlot();
        end
    end

    function updateAll()
        if strcmp(modeDrop.Value,'Cartesian (IK)')
            onTargetEdited();
        else
            targetXYZ = fk_pos(theta,L1,L2,L3);
            xField.Value=targetXYZ(1); yField.Value=targetXYZ(2); zField.Value=targetXYZ(3);
        end
        updatePlot();
    end

    function updatePlot()
        P = fk_points(theta,L1,L2,L3);
        set(hLink,'XData',P(:,1),'YData',P(:,2),'ZData',P(:,3));
        set(hJ,'XData',P(:,1),'YData',P(:,2),'ZData',P(:,3));

        ee = fk_pos(theta,L1,L2,L3);
        set(hEE,'XData',ee(1),'YData',ee(2),'ZData',ee(3));

        set(hTarget,'XData',targetXYZ(1),'YData',targetXYZ(2),'ZData',targetXYZ(3));

        reach = L1+L2+L3;
        xlim(ax,[-reach reach]); ylim(ax,[-reach reach]); zlim(ax,[0 reach]);
        title(ax,sprintf('Target [%.1f %.1f %.1f] mm',targetXYZ(1),targetXYZ(2),targetXYZ(3)));
        drawnow limitrate;
    end

    function sendToArduino()
        if isempty(sp) || ~isvalid(sp) || ~sendEnabled, return; end
        if all(abs(theta - lastSentTheta) < 0.05), return; end
        lastSentTheta = theta;

        msg = sprintf("A,%.2f,%.2f,%.2f\n", theta(1),theta(2),theta(3));
        try
            write(sp, msg, "string");
        catch
            status.Text = 'Status: Serial write failed';
        end
    end

    function onClose(~,~)
        try
            if ~isempty(tSend) && isvalid(tSend)
                stop(tSend); delete(tSend);
            end
        catch, end
        try
            if ~isempty(sp), clear sp; end
        catch, end
        delete(fig);
    end
end

%% -------- KINEMATICS --------
function p = fk_pos(theta,L1,L2,L3)
t1=theta(1); t2=theta(2); t3=theta(3);
r = L2*cosd(t2) + L3*cosd(t2+t3);
z = L1 + L2*sind(t2) + L3*sind(t2+t3);
x = r*cosd(t1);
y = r*sind(t1);
p = [x y z];
end

function P = fk_points(theta,L1,L2,L3)
t1=theta(1); t2=theta(2); t3=theta(3);
base=[0 0 0];
shoulder=[0 0 L1];

r1=L2*cosd(t2);
z1=L1 + L2*sind(t2);
elbow=[r1*cosd(t1), r1*sind(t1), z1];

ee=fk_pos(theta,L1,L2,L3);
P=[base; shoulder; elbow; ee];
end

function th = ik_solve(p,L1,L2,L3, elbowSign)
x=p(1); y=p(2); z=p(3);
t1 = atan2d(y,x);
r = hypot(x,y);
zp = z - L1;

D = (r^2 + zp^2 - L2^2 - L3^2) / (2*L2*L3);
if abs(D) > 1
    th=[nan nan nan]; return;
end
t3 = atan2d(elbowSign*sqrt(1-D^2), D);
t2 = atan2d(zp,r) - atan2d(L3*sind(t3), L2 + L3*cosd(t3));
th=[t1 t2 t3];
end

function th = clampTheta(th,lim)
for i=1:3
    th(i)=min(max(th(i),lim(i,1)),lim(i,2));
end
end
