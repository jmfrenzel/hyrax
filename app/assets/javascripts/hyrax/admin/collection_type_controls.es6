// The editor for the CollectionTypeParticipant
// Add search for user/group to the edit an admin set's participants page
import Participants from 'hyrax/admin/collection_type/participants'

export default class {
    constructor(elem) {
        let participants = new Participants(elem.find('#participants'))
        participants.setup();
        this.form = elem.find('form.edit_collection_type')
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
