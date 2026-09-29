%% 1. 讀取彩色圖像
img_rgb = imread('image.png'); 

%% 2. 彩色直方圖均衡化 (RGB -> HSV -> RGB)
img_hsv = rgb2hsv(img_rgb);

% 僅對 V (亮度) 通道進行直方圖均衡化
img_hsv(:, :, 3) = histeq(img_hsv(:, :, 3));

% 將均衡化後的 HSV 圖像轉換回 RGB 空間
img_equalized_rgb = hsv2rgb(img_hsv);

% 提取原圖與均衡化後的亮度通道（轉成 uint8 格式，以便 imhist 呈現 0-255 範圍）
img_hsv_orig = rgb2hsv(img_rgb);
v_orig = im2uint8(img_hsv_orig(:, :, 3));
v_eq = im2uint8(img_hsv(:, :, 3));

%% 3. 轉換為浮點數以進行後續濾波
f_float = im2double(img_hsv(:, :, 3));          

%% 4. 邊緣檢測 - 三種方法
% ========== 方法 A：Laplacian operator ==========
w_laplacian_4 = fspecial('laplacian', 0);  % [0 1 0; 1 -4 1; 0 1 0] 
w_laplacian_8 = [1 1 1; 1 -8 1; 1 1 1];

% 對影像進行 Laplacian 濾波
lap_4 = imfilter(f_float, w_laplacian_4, 'replicate');
lap_8 = imfilter(f_float, w_laplacian_8, 'replicate');

% Laplacian 邊緣檢測：取絕對值並做正規化與二值化作為邊緣強度
img_edges_laplacian_4 = imbinarize(mat2gray(abs(lap_4)));
img_edges_laplacian_8 = imbinarize(mat2gray(abs(lap_8)));

% ========== 方法 B：Sobel operator ==========
sv = fspecial('sobel'); 
sh = sv';                

% 計算水平和垂直梯度
Gx = imfilter(f_float, sh, 'replicate');
Gy = imfilter(f_float, sv, 'replicate');

% 計算梯度幅值
img_sobel_magnitude = sqrt(Gx.^2 + Gy.^2);
% Sobel 邊緣檢測：正規化並二值化得到邊緣圖
img_edges_sobel = imbinarize(mat2gray(img_sobel_magnitude));

% ========== 方法 C：Canny 邊緣檢測（直接使用 edge 函數）==========
edges_r_canny = edge(img_equalized_rgb(:, :, 1), 'Canny');
edges_g_canny = edge(img_equalized_rgb(:, :, 2), 'Canny');
edges_b_canny = edge(img_equalized_rgb(:, :, 3), 'Canny');
img_edges_canny = edges_r_canny | edges_g_canny | edges_b_canny;

%% 5. 結果展示
% --- 原始影像 ---
figure;
imshow(img_rgb);
title('1) Original Image', 'FontSize', 12);

% --- 原始亮度直方圖 ---
figure;
imhist(v_orig); 
grid on;
title('1) Original Intensity Histogram', 'FontSize', 12);
ylabel('Pixel Count');

% --- 均衡化後的亮度直方圖 ---
figure;
imhist(v_eq);
grid on;
title('1) Equalized Intensity Histogram', 'FontSize', 12);
ylabel('Pixel Count');

% --- 均衡化後的黑白影像（亮度）---
figure;
imshow(v_eq);
title('1) Processed Image (Grayscale)', 'FontSize', 12);

% --- 均衡化後的彩色影像（RGB）---
figure;
imshow(img_equalized_rgb);
title('1) Processed Image (Color)', 'FontSize', 12);

% --- Laplacian (4-neighbor) 邊緣檢測 ---
figure;
imshow(lap_4);
title('2A) Laplacian Edges (4-neighbor)', 'FontSize', 12);

figure;
imshow(img_edges_laplacian_4);
title('2A) Laplacian Edge (4-neighbor) with Normalization & Binarization', 'FontSize', 12);

% --- Laplacian (8-neighbor) 邊緣檢測 ---
figure;
imshow(lap_8);
title('2A) Laplacian Edges (8-neighbor)', 'FontSize', 12);

figure;
imshow(img_edges_laplacian_8);
title('2A) Laplacian Edges (8-neighbor) with Normalization & Binarization', 'FontSize', 12);

% --- Sobel 邊緣檢測 ---
figure;
imshow(img_sobel_magnitude);
title('2B) Sobel Edges (Gradient Magnitude)', 'FontSize', 12);

figure;
imshow(img_edges_sobel);
title('2B) Sobel Edges with Normalization & Binarization', 'FontSize', 12);

% --- Canny 邊緣檢測 ---
figure;
imshow(img_edges_canny);
title('2C) Detected Edges - Canny', 'FontSize', 12);