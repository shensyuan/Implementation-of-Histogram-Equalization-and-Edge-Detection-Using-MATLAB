%% 自製直方圖均衡化 vs. MATLAB 內建 histeq 比較
clear; close all; clc;

%% 1. 讀取影像並取出亮度通道
img_rgb = imread('image.png');
img_hsv = rgb2hsv(img_rgb);
V = im2uint8(img_hsv(:, :, 3));

%% 2. 三種均衡化
[V_my, T] = My_histeq(V);     % 自己實作
V_h64  = histeq(V);           % 內建預設：輸出只有 64 個灰階
V_h256 = histeq(V, 256);      % 內建，指定 256 個灰階

%% 3. 數值比較
d = abs(double(V_my) - double(V_h256));
fprintf('Custom vs histeq(V, 256): Mean diff %.2f, Max diff %d, Identical pixels %.1f%%\n', ...
    mean(d(:)), max(d(:)), 100 * mean(d(:) == 0));
fprintf('Mean luminance: Original %.1f, Custom %.1f, histeq(V, 256) %.1f\n', ...
    mean(double(V(:))), mean(double(V_my(:))), mean(double(V_h256(:))));
fprintf('Gray levels used: Original %d, Custom %d, histeq default %d, histeq(V, 256) %d\n', ...
    numel(unique(V)), numel(unique(V_my)), numel(unique(V_h64)), numel(unique(V_h256)));

%% 4. 影像與直方圖並排
figure('Name', 'Histogram Equalization Comparison', 'Position', [100 100 1400 650]);
subplot(2, 4, 1); imshow(V);      title('Original Intensity');
subplot(2, 4, 2); imshow(V_my);   title('Custom my\_histeq');
subplot(2, 4, 3); imshow(V_h64);  title('histeq (Default 64 Levels)');
subplot(2, 4, 4); imshow(V_h256); title('histeq (256 Levels)');
subplot(2, 4, 5); imhist(V);      title('Original Histogram');
subplot(2, 4, 6); imhist(V_my);   title('Custom');
subplot(2, 4, 7); imhist(V_h64);  title('histeq (64 Levels)');
subplot(2, 4, 8); imhist(V_h256); title('histeq (256 Levels)');

%% 5. 映射曲線：均衡化的本質就是用 CDF 當作亮度轉換函數
figure('Name', 'Mapping Curve');
plot(0:255, T, 'LineWidth', 1.5); hold on;
plot(0:255, 0:255, '--', 'Color', [0.6 0.6 0.6]);
axis([0 255 0 255]); axis square; grid on;
xlabel('Input Intensity'); ylabel('Output Intensity');
legend('Custom Mapping T(k)', 'Identity (y = x)', 'Location', 'southeast');
title('Intensity Mapping Curve');



%% 6. 累積直方圖：均衡化後應接近一條直線

figure('Name', 'Cumulative Distribution');
plot([0 255], [0 1], 'k--', 'LineWidth', 2.5); hold on;   % 理想均勻分布，黑色粗虛線
plot(0:255, cumsum(imhist(V))    / numel(V), 'LineWidth', 1.5);
plot(0:255, cumsum(imhist(V_my)) / numel(V), 'LineWidth', 1.5);
grid on; xlim([0 255]); ylim([0 1]);
xlabel('Intensity'); ylabel('Cumulative Ratio');
legend('Ideal Uniform Distribution', 'Original', 'Custom Equalized', 'Location', 'southeast');
title('Cumulative Distribution Function (CDF)');
%% 7. 套回彩色影像（只換 V 通道）
hsv_my = img_hsv;
hsv_my(:, :, 3) = im2double(V_my);
rgb_my = hsv2rgb(hsv_my);
hsv_builtin = img_hsv;
hsv_builtin(:, :, 3) = im2double(V_h256);
rgb_builtin = hsv2rgb(hsv_builtin);
figure('Name', 'Color Results');
subplot(1, 3, 1); imshow(img_rgb);     title('Original');
subplot(1, 3, 2); imshow(rgb_my);      title('Custom Equalized');
subplot(1, 3, 3); imshow(rgb_builtin); title('histeq(V, 256)');

figs = findall(groot, 'Type', 'figure');
for i = 1:numel(figs)
    saveas(figs(i), sprintf('result_%d.png', figs(i).Number));
end
disp('Saved!');