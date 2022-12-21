%% Loop over multiple frames and create a movie
fig = figure('color', 'w', 'position', [440   171   852   626]);
ax = axes(fig);
plt = plot(ax, NaN, NaN, 'k');
axis(ax, 'equal', 'off')

xmin = 67; xmax = 78;
y = 854;
nframes = 32 * 32;

xx = linspace(xmin, xmax, nframes / 2);
xx = [xx , fliplr(xx)];

v = VideoWriter('vmult.avi');

v.FrameRate = 15; % defaults framerate is 30
open(v);

for k = 1 : nframes
    x = xx(k);
    % Table of x modulo y, the trick is to represent it using the circle equation for complex numbers
    in = [1:(y-1)].';
    cir = @(x) exp(-1i .* x .* 2 .* pi + 1i .* pi / 2);
    
    % Update the display, this will be way to slow if each line is an object.
    % The trick is to have a single line object with NaNs allowing to display separate segments
    toplot = ([cir(in / y) cir(mod(in * x , y) ./ y )  in.*NaN].');
    toplot = toplot(:);
    
    % update graphics
    plt.set('xdata', real(toplot), 'ydata', imag(toplot))
    
    frame = getframe(fig);
    writeVideo(v,frame);
end

close(v);

% following command using ffmpeg will make the video a more manageable size:
% ffmpeg -i input.avi -c:v libx264 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p output.mkv