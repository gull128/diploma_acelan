# frozen_string_literal: true
class FdsController < ApplicationController
  include ActiveStorage::SetCurrent
  before_action :authorize_user
  @error_text = ""
  def solve
    path = Beekeeper::Bridge.send({ str: 0})
    path = path[0..-2]

    file_res = ""
    # Получаем текущее время в формате ISO 8601
    timestamp = Time.now.strftime('_%Y_%m_%dT%H_%M_%S')
    puts timestamp
    fdm_params = params[:fds]
    File.open("#{path}\\Data\\ParamSid2024.txt", "w") do |f|
      f.write(fdm_params['x'].to_s + "\n") #isk
      f.write(fdm_params['y'].to_s + "\n") #jsk
      f.write(fdm_params['substance'].to_s + "\n") #SGryas
      f.write(fdm_params['diffusion'].to_s + "\n") #AlfG
      f.write(fdm_params['speedx'].to_s + "\n") #WKoef
      f.write(fdm_params['new_or_old_file'].to_s + "\n") #NewFile
      f.write(fdm_params['GetVelos'].to_s + "\n") #GetVelos файл скоростей
      if fdm_params['new_or_old_file'] == 'F' #if new file
        f.write(fdm_params['file_name'].to_s + "\n") #GetS_K входные данные
        file_res = fdm_params['file_name'].to_s.gsub(/\.res$/, '') + '_' + fdm_params['GetVelos'].to_s.gsub(/\.res$/, '') + "#{timestamp}" + ".res"
        f.write(file_res) #PutS_K выходные данные
      else
        f.write('S_K_' + "\n") #GetS_K входные данные
        file_res = 'S_K_'+fdm_params['x'].to_s + '_' + fdm_params['y'].to_s + '_' + fdm_params['diffusion'].to_s + '_' + fdm_params['GetVelos'].to_s.gsub(/\.res$/, '') + "#{timestamp}" + ".res"
        f.write(file_res+ "\n") #PutS_K выходные данные
      end
    end


    # make ParamCalc.json
    File.open("#{path}\\Data\\ParamCalc.txt", "w") do |f|
      f.write(fdm_params['tau'].to_s + "\n") #tau
      f.write(fdm_params['time_steps'].to_s + "\n") #itt
      f.write(fdm_params['hx'].to_s + "\n") #hx
      f.write(fdm_params['hy'].to_s + "\n") #hy
      f.write(fdm_params['Shema'].to_s + "\n") #Shema
      f.write(fdm_params['const_or_var_diff_coeff'].to_s + "\n") #c_coef
      f.write(fdm_params['wind_condition'].to_s + "\n") #alf
      f.write(fdm_params['calculation_method'].to_s + "\n") #MS = MethodSLAU
    end

    # Вызываем команду с передачей timestamp в качестве параметра
    #system "cd ./vendor/FDM & FDM_Calc.exe 144 98 6300 ParamCalc.txt ParamSid2024.txt out.txt '#{timestamp}'"

    answer = Beekeeper::Bridge.send({ num1: 144, num2:98,
                             num1xnum2: 6300,
                             fileName1:"ParamCalc.txt",
                             fileName2:"ParamSid2024.txt",
                                      time:"#{timestamp}" })
    puts "#{path}\\Data\\#{file_res}"
    if answer == "OK\n"
      sleep(2)
      numeric_result = NumericResult.new
      numeric_result.images.attach(io: File.open("#{path}\\Data\\Maps#{timestamp}.png"), filename: "Maps#{timestamp}.png")
      numeric_result.images.attach(io: File.open("#{path}\\Data\\Lines#{timestamp}.png"), filename: "Lines#{timestamp}.png")
      numeric_result.images.attach(io: File.open("#{path}\\Data\\Anim08_05#{timestamp}.gif"), filename: "Anim08_05#{timestamp}.gif")
      #file_res = "S_K_70_65_100_w1.res"
      numeric_result.solution.attach(io: File.open("#{path}\\Data\\#{file_res}"), filename: "#{file_res}")
      numeric_result.save

      redirect_to "/fds/result/#{numeric_result.id}"
    else
      session[:error_text] = answer.to_s
      redirect_to "/fds/error"
    end
  end

  def result
    @numeric_result = NumericResult.find_by_id(params[:id])
  end

  def error
    @error_text = session.delete(:error_text)
    render 'error'
  end

end