// The editor for the AdminSets
// Add search for user/group to the edit an admin set's participants page
// Add search for thumbnail to the edit descriptions
import Visibility from 'hyrax/admin/admin_set/visibility'
import Participants from 'hyrax/admin/admin_set/participants'
import ThumbnailSelect from 'hyrax/thumbnail_select'

export default class {
    constructor(elem) {
        let url = window.location.pathname.replace('edit', 'files')
        this.thumbnailSelect = new ThumbnailSelect(url, elem.find('#admin_set_thumbnail_id'))

        let participants = new Participants(elem.find('#participants'))
        participants.setup();

        let visibilityTab = new Visibility(elem.find('#visibility'));
        visibilityTab.setup();
        this.form = elem.find('form.edit_admin_set')
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
