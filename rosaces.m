% We go through the overhead of creating objects only once, we will subsequently only update the properties
fig = figure('color', 'w', 'position', [440   171   852   626]);
ax = axes(fig);
plt = plot(ax, NaN, NaN, 'k');
axis(ax, 'equal', 'off')

% Display a single image
x = 78;
y = 854;
% Table of x modulo y, the trick is to represent it using the circle equation for complex numbers
in = [1:(y-1)].';
cir = @(x) exp(-1i .* x .* 2 .* pi + 1i .* pi / 2);

% Update the display, this will be way to slow if each line is an object.
% The trick is to have a single line object with NaNs allowing to display separate segments
toplot = ([cir(in / y) cir(mod(in * x , y) ./ y )  in.*NaN].');
toplot = toplot(:);

% update graphics
plt.set('xdata', real(toplot), 'ydata', imag(toplot))
