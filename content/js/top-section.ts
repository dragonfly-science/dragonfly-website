import animateScrollTo from "animated-scroll-to";

const TopSection = () => {
    $('a[href="#top-section"]').click((e) => {
        e.preventDefault();

        const headerH = $(".main-header").height();
        const sectionOffset = $("#top-section").offset().top;

        animateScrollTo(sectionOffset - headerH);
    });

    // $('a[href="#contact"]').click((e) => {
    //     e.preventDefault();

    //     // const scrollingElement = document.scrollingElement || document.body;
    //     // scrollingElement.scrollTop = scrollingElement.scrollHeight;

    //     window.scrollTo({
    //         top: document.body.clientHeight + window.innerHeight,
    //         left: 0,
    //         behavior: "smooth",
    //     });

    //     // animateScrollTo(scrollingElement.scrollHeight);
    // });
};

export default TopSection;
