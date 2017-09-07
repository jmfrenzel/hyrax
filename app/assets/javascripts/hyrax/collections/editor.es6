import ThumbnailSelect from 'hyrax/thumbnail_select'

// Controls the behavior of the Collections edit form
// Add search for thumbnail to the edit descriptions
export default class {
  constructor(elem) {
    let url =  window.location.pathname.replace('edit', 'files')
    let field = elem.find('#collection_thumbnail_id')
    this.thumbnailSelect = new ThumbnailSelect(url, field);
    this.form = elem.find('form.editor')
    this.refererAnchor = this.addRefererAnchor()
    this.watchActiveTab()
    this.setRefererAnchor($('.nav-tabs li.active a').attr('href'))
  }

  addRefererAnchor() {
    let referer_anchor_input = $('<input>').attr({type: 'hidden', id: 'referer_anchor', name: 'referer_anchor'}) 
    this.form.append(referer_anchor_input)
    return referer_anchor_input
  }

  setRefererAnchor(id) {
    this.refererAnchor.val(id)
  }

  watchActiveTab() {
    $('.nav-tabs a').on('shown.bs.tab', (e) => this.setRefererAnchor($(e.target).attr('href')))
  }

}
