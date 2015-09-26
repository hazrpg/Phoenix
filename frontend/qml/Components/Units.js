var formFactor = "desktop"
var desktopDistanceToDisplay = 0.5
var desktopPixelDensity = 112

var tvDistanceToDisplay = 2.0
// 1080p on a 42" screen
var tvPixelDensity = 52

function dtPx(desktopPixels) {
    var distanceToDisplay = formFactor === "desktop" ? desktopDistanceToDisplay : tvDistanceToDisplay
    var pixelDensity = formFactor === "desktop" ? desktopPixelDensity : tvPixelDensity
    var factorFromDesktop = pixelDensity / desktopPixelDensity * distanceToDisplay / desktopDistanceToDisplay
    return desktopPixels * factorFromDesktop
}

function tvPx(tvPixels) {
    var distanceToDisplay = formFactor === "desktop" ? desktopDistanceToDisplay : tvDistanceToDisplay
    var pixelDensity = formFactor === "desktop" ? desktopPixelDensity : tvPixelDensity
    var factorFromTv = pixelDensity / tvPixelDensity * distanceToDisplay / tvDistanceToDisplay
    return tvPixels * factorFromTv
}


