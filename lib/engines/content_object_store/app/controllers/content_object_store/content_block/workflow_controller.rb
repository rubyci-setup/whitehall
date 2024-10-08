class ContentObjectStore::ContentBlock::WorkflowController < ContentObjectStore::BaseController
  def publish
    edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(edition.document.block_type)
    new_edition = ContentObjectStore::PublishEditionService.new(
      schema,
    ).call(edition)
    redirect_to content_object_store.content_object_store_content_block_document_path(new_edition.document),
                flash: { notice: "#{new_edition.block_type.humanize} created successfully" }
    # TODO: error handling
    # else
    #   redirect_to admin_edition_path(@edition), alert: edition_publisher.failure_reason
    # end
  end

  def update
    content_block_edition = ContentObjectStore::ContentBlock::Edition.find(params[:id])
    @schema = ContentObjectStore::ContentBlock::Schema.find_by_block_type(content_block_edition.document.block_type)

    new_edition_params = edition_params.merge!(scheduled_publication_params)
    change_dispatcher = params[:schedule_publishing] == "schedule" ? ContentObjectStore::ChangeDispatcher::Schedule.new : ContentObjectStore::ChangeDispatcher::Now.new
    result = ContentObjectStore::UpdateEditionService.new(
      @schema,
      content_block_edition,
      change_dispatcher,
    ).call(new_edition_params)
    new_content_block_edition = result.object

    if result.success?
      redirect_to content_object_store.content_object_store_content_block_document_path(new_content_block_edition.document),
                  flash: { notice: result.message }
    else
      @content_block_edition = result.object
      @content_block_document = content_block_edition.document
      @edition_params = new_edition_params

      render "content_object_store/content_block/editions/schedule_publishing"
    end
  end
end
