Qt.include("Units.js")

function fontSizeToPixels(size) {
    if (formFactor === "desktop") {
        switch (size) {
            case "small": return dtPx(12)
            case "medium": return dtPx(15)
            case "large": return dtPx(17)
            case "x-large": return dtPx(20)
            case "xx-large": return dtPx(30)
        }
    } else if (formFactor === "tv") {
        switch (size) {
            case "ex-small": return 12
            case "small": return tvPx(30)
            case "medium": return tvPx(35) // NOT USED IN TV (ONLY IN FILTERS)
            case "large": return tvPx(40)
            case "x-large": return tvPx(48)
            case "xx-large": return tvPx(60)
            case "xxx-large": return tvPx(90)
        }
    } else if (formFactor === "tablet") {
            switch (size) {
                case "small": return dtPx(13)
                case "medium": return dtPx(15)
                case "large": return dtPx(17)
                case "x-large": return dtPx(20)
                case "xx-large": return dtPx(30)
            }
    }
}
