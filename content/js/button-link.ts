export default () => {
    console.log($('.button-link'))
    $('.button-link').on('click', function(this: HTMLElement, e: Event) {
        e.stopPropagation()

        console.log($(this).data('href'))
        location.href = $(this).data('href')
    })
}
