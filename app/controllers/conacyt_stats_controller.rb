class ConacytStatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session
  before_action :authenticate, :only => 'padron'

  def authenticate
    authenticate_or_request_with_http_basic do |user, password|
      user == ENV['CONACYT_USER'] && password == ENV['CONACYT_PASS']
    end
  end

  def padron
    usuarios = User.select('email, firstname, phone, paternal_surname, maternal_surname')

    d = { depositarios: []}

    usuarios.each do |u|
        d[:depositarios].push(
          {
            correo: u.email,
            nombre: u.firstname,
            numTel: u.phone,
            pApellido: u.paternal_surname,
            sApellido: u.maternal_surname

          }
        )
    end

    render :json => d

  end
  
  def articulos

    a = { articulos: []}

      articulos = WorkViewStat.group(:work_id).sum(:work_views)

      articulos.each do |key, value|
        work = ActiveFedora::Base.where(id: key)

        if !work.empty? then
          a[:articulos].push(
             {
                id: work.id,
                numero:  value
             }
          )
        end
      end

      render :json => a
  end

  def autores

    a = { autores: []}

    works = WorkViewStat.group(:work_id).sum(:work_views)

    works.each do |key, value|
      work = ActiveFedora::Base.where(id: key)
      if !work.empty? then
        
        esta = a[:autores].index { |h| h[:nombre] == work[0].creator[0] }

        if esta then

          a[:autores][esta][:numero] =  a[:autores][esta][:numero] + value

        else

          autor = work[0].creator[0]
          a[:autores].push(
            {
              nombre: autor,
              numero:  value
            }
          )
        end
      end
    end

    render :json => a
  end

  def descargas
    
    d = { descargas: []}

      descargas = FileDownloadStat.group(:file_id).sum(:downloads)

      descargas.each do |key, value|
        # work_key = FileSet.where(id: key)
        # work = ActiveFedora::Base.where(work_key[0].parent)
         work = nil
	 begin work = FileSet.find(key).parent rescue work = nil end
        unless work.nil? then
          esta = d[:descargas].index { |h| h[:id] == work.id }
          if esta then

            d[:descargas][esta][:numero] =  d[:descargas][esta][:numero] + value

          else

            id = work.id
            d[:descargas].push(
              {
                id: id,
                numero:  value
              }
            )
          end
        end
      end

      render :json => d
  end

end
