class Admin::DocumentCollectionEmailSubscriptionsController < Admin::BaseController
  include Admin::DocumentCollectionEmailOverrideHelper
  before_action :load_document_collection
  before_action :authorise_user
  layout "design_system"

  def edit; end

  def update
    if user_has_selected_taxonomy_topic_emails?
      if params[:selected_taxon_content_id].blank?
        build_flash("selected_taxon_content_id")
        return redirect_to admin_document_collection_edit_email_subscription_path(@collection)
      elsif params["email_override_confirmation"].blank?
        build_flash("email_override_confirmation")
        return redirect_to admin_document_collection_edit_email_subscription_path(@collection)
      else
        @collection.update!(taxonomy_topic_email_override: params[:selected_taxon_content_id])
      end
    else
      @collection.update!(taxonomy_topic_email_override: nil)
    end
    build_flash("notice")
    redirect_to edit_admin_document_collection_path(@collection)
  rescue ActiveRecord::RecordInvalid
    redirect_to edit_admin_document_collection_path(@collection)
  end

private

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def authorise_user
    redirect_to edit_admin_document_collection_path(@collection) unless current_user.can_edit_email_overrides?
  end

  def build_flash(key)
    flash[key] = {
      "selected_taxon_content_id" => "You must choose a topic",
      "email_override_confirmation" => "You must confirm you’re happy with the email notification settings",
      "notice" => "You’ve selected the email notification settings. #{confirmation_message}. You will not be able to change these settings after you publish the collection.",
    }[key]
  end

  def confirmation_message
    if @collection.taxonomy_topic_email_override.present?
      "You’ve chosen ‘Emails about the topic’ and the topic #{taxonomy_topic_email_override_title(@collection)}"
    else
      "You’ve chosen ‘Emails about the page’"
    end
  end

  def user_has_selected_taxonomy_topic_emails?
    params[:override_email_subscriptions] == "true"
  end
end
