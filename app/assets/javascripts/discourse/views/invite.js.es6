import ModalBodyView from "discourse/views/modal-body";

export default ModalBodyView.extend({
  templateName: 'modal/invite',

  title: function() {
    if (this.get('controller.isMessage')) {
      return I18n.t('topic.invite_private.title');
    } else if (this.get('controller.invitingToTopic')) {
      return I18n.t('topic.invite_reply.title');
    } else {
      return I18n.t('user.invited.create');
    }
  }.property('controller.{invitingToTopic,isMessage}')

});
