const requestAF = (): void => {
    const main = document.getElementById("main-container");
    const footer = document.getElementById("main-footer");

    main.style.marginBottom = `${footer.clientHeight}px`;
};

const calcMainBottomMargin = (): void => {
    requestAnimationFrame(requestAF);
};

const Footer = (): void => {
    "resize oreientationchange scroll".split(" ").forEach((e) => {
        window.addEventListener(e, calcMainBottomMargin, false);
    });
};

export default Footer;
