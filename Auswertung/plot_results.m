%recordings = [csvread('feugen.csv')];
%classes = [csvread('ae.csv')];
recordings = nagi;
classes = ann_nagi;

sum_acc = sum(recordings(:,2));
num_recordings = size(recordings);
num_recordings = num_recordings(1);

recordings_new = zeros(sum_acc, 7);
classes_new = zeros(sum_acc, 1);

% expand recordings by acc
k = 1;
for i = 1:num_recordings
    for j = 1:recordings(i, 2)
       recordings_new(k, :) = recordings(i, :);
       classes_new(k, :) = classes(i, :);
       k = k + 1;
    end
end

recordings = recordings_new;
time = [0:1:sum_acc-1] ./ 100;
time = time';
    
% walking
%start = 55370;
%stop = 62320;

% making bread
%start = 39837;
%stop = 42168;

% drink
%start = 50550;
%stop = 60890;

% all
start = + 10000;
stop = sum_acc - 10000;

delta = stop - start;
window_size = 20;

acceleration_x = recordings(:,3);
acceleration_y = recordings(:,4);
acceleration_z = recordings(:,5);

cap = recordings(:,6);

% smooth all recorded data by average filter
average_kernel = ones(100, 1) * 0.0125;
%cap = conv(cap, average_kernel, 'same');
%acceleration_x = conv(acceleration_x, average_kernel, 'same');
%acceleration_y = conv(acceleration_y, average_kernel, 'same');
%acceleration_z = conv(acceleration_z, average_kernel, 'same');

% resulting values
res_cap = cap(start:stop);
res_acceleration_x = acceleration_x(start:stop);
res_acceleration_y = acceleration_y(start:stop);
res_acceleration_z = acceleration_z(start:stop);
% res_time = time(start:stop); % for continuos time
res_time = ((0:(delta)) * 0.01)';

subplot(2,1,1);
set(gca,'LooseInset',get(gca,'TightInset'));
set (gca, 'box', 'on');
plot(res_time, res_cap, '-m', 'LineWidth', 1);
axis([res_time(1) res_time(delta) (min(res_cap)-1)  (max(res_cap)+1)]);
ylabel('frequency count');
title('Capacitive proximity sensor');

subplot(2,1,2);
set (gca, 'box', 'on');
set(gca,'LooseInset',get(gca,'TightInset'));
hold on;
plot(res_time, res_acceleration_x, '-r', 'LineWidth', 1);
plot(res_time, res_acceleration_y, '-b', 'LineWidth',1);
plot(res_time, res_acceleration_z, '-g', 'LineWidth',1);
hold off;
axis([res_time(1) res_time(delta) 0 256]);
ylabel('3D acceleration');
xlabel('time / seconds');
title('Accelerometer');