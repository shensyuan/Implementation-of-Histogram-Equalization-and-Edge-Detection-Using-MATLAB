function [out, T] = My_histeq(img)
if ~isa(img, 'uint8')
    error('輸入必須是 uint8 灰階影像');
end

total = numel(img);

% 1. 統計直方圖：每個亮度值 (0~255) 出現幾次
counts = zeros(256, 1);
for k = 1:total   % MATLAB 索引從 1 開始
    v = double(img(k)) + 1;
    counts(v) = counts(v) + 1;
end

% 2. 機率密度 (PDF) 與累積分布 (CDF)
pdf = counts / total;
cdf = cumsum(pdf);

% 3. 建立映射表
cdf_min = min(cdf(cdf > 0));
if cdf_min >= 1
    T = (0:255)';
    out = img;
    return;
end
T = round((cdf - cdf_min) / (1 - cdf_min) * 255);
T = max(T, 0);   % 小於最暗值的亮度（實際不存在於影像中）夾到 0

% 4. 查表：把每個像素的亮度換成映射後的值
out = uint8(T(double(img) + 1));
end