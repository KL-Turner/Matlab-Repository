function [imageGrad] = ReadBinFileU8MatrixGradient_2P(fileName, height, width)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the pixel intensity of the whisker movie and output the the intensity vals as w x h x time.
%________________________________________________________________________________________________________________________
%
%   Inputs: File name ending in '_WhiskerCam.bin' that contains a movie of the whiskers. image height and width in pixels.
%
%   Outputs: imageout - [array, u8 integer] the measured intensity values organized as
%            [image width, image height, frame number].
%
%   Last Revised: March 21st, 2019
%________________________________________________________________________________________________________________________

% Calculate pixels per frame for fread
pixelsPerFrame = width*height;

% open the file , get file size , back to the begining
fid = fopen(fileName);
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
fseek(fid, 0, 'bof');

% Identify the number of frames to read. Each frame has a previously
% defined width and height (as inputs), U8 has a depth of 1.
nFrameToRead = floor(fileSize/(pixelsPerFrame));
disp(['ReadBinFileU8MatrixGradient: ' num2str(nFrameToRead) ' frames to read.']); disp(' ')

% Pre-allocate
imageGrad = int8(zeros(width, height, nFrameToRead));
for a = 1:nFrameToRead
    z = fread(fid, pixelsPerFrame, '*uint8', 0, 'l');
    indImg = reshape(z(1:pixelsPerFrame), width, height);
    imageGrad(:, :, a) = int8(gradient(double(indImg)));
end
fclose(fid);

end

