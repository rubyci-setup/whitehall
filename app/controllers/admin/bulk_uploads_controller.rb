class Admin::BulkUploadsController < Admin::BaseController
  before_action :find_edition
  before_action :limit_edition_access!
  before_action :enforce_permissions!
  before_action :prevent_modification_of_unmodifiable_edition
  layout :get_layout

  def new
    @zip_file = BulkUpload::ZipFile.new
    render(preview_design_system_user? ? "new" : "new_legacy")
  end

  def upload_zip
    filename = params.fetch(:bulk_upload_zip_file, {})[:zip_file]
    @zip_file = BulkUpload::ZipFile.new(filename)
    if @zip_file.valid?
      @bulk_upload = BulkUpload.from_files(@edition, @zip_file.extracted_file_paths)
      @zip_file.cleanup_extracted_files
      render(preview_design_system_user? ? "set_titles" : "set_titles_legacy")
    else
      render(preview_design_system_user? ? "new" : "new_legacy")
    end
  end

  def create
    @bulk_upload = BulkUpload.new(@edition)
    @bulk_upload.attachments_attributes = create_params[:attachments_attributes]
    @bulk_upload.attachments.each do |attachment|
      attachment.attachment_data.attachable = @edition
    end
    if @bulk_upload.save_attachments
      redirect_to admin_edition_attachments_path(@edition)
    else
      render :set_titles
    end
  end

private

  def get_layout
    return "admin" unless preview_design_system_user?

    case action_name
    when "new", "upload_zip"
      "design_system"
    else
      "admin"
    end
  end

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def create_params
    params.require(:bulk_upload).permit(attachments_attributes: [
      { attachment_data_attributes: %i[file_cache to_replace_id] },
      :id,
      :title,
      :locale,
      :isbn,
      :unique_reference,
      :command_paper_number,
      :unnumbered_command_paper,
      :hoc_paper_number,
      :unnumbered_hoc_paper,
      :parliamentary_session,
    ])
  end
end
