require 'net/http'
require 'json'
require 'uri'
require 'optparse'

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red = colorize(31)
  def green = colorize(32)
  def yellow = colorize(33)
  def blue = colorize(34)
  def pink = colorize(35)
end

class LoadBalancerTest
  BAR_WIDTH = 50

  def initialize(options = {})
    @algorithm = options[:algorithm] || 'round-robin'
    @requests = options[:requests] || 30
    @test_failures = options[:test_failures] || false

    @url = URI('http://localhost/api/server-id')

    @responses = []
    @start_time = nil
    @errors = []
  end

  def run
    puts "\n🚀 #{'Iniciando teste de Load Balancer'.green}"
    puts "📊 #{"Algoritmo: #{@algorithm}".blue}"
    puts "📊 #{"Requisições: #{@requests}".blue}\n\n"

    @start_time = Time.now

    if @test_failures
      test_with_failures
    else
      test_normal_operation
    end

    print_summary
  end

  private

  def test_normal_operation
    threads = []
    @requests.times do |i|
      threads << Thread.new do
        make_request_with_logging(i + 1)
      end
      sleep 0.05
    end
    threads.each(&:join)
  end

  def test_with_failures
    puts "🔥 #{'Simulando falhas...'.red}\n"

    (@requests / 3).times do |i|
      make_request_with_logging(i + 1)
      sleep 0.1
    end

    puts "\n💥 #{'Simulando falha no Backend 1...'.red}\n"
    system('docker compose stop backend1')
    sleep 2

    (@requests / 3).times do |i|
      make_request_with_logging(i + 1 + @requests / 3)
      sleep 0.1
    end

    puts "\n🔄 #{'Recuperando Backend 1...'.green}\n"
    system('docker compose start backend1')
    sleep 2

    (@requests / 3).times do |i|
      make_request_with_logging(i + 1 + 2 * @requests / 3)
      sleep 0.1
    end
  end

  def make_request_with_logging(num)
    response = make_request
    data = JSON.parse(response)
    server_id = data['server_id']
    load = data['load']
    @responses << { id: server_id, load: load }
    print_request(num, server_id, load)
  rescue StandardError => e
    @errors << e
    puts "❌ #{"Erro na requisição #{num}:".red} #{e.message}"
  end

  def make_request
    http = Net::HTTP.new(@url.host, @url.port)
    request = Net::HTTP::Get.new(@url)

    request['X-Load-Balancer-Type'] = @algorithm

    response = http.request(request)
    response.body
  end

  def print_request(num, server_id, load)
    color = case server_id
            when 'Backend 1' then :green
            when 'Backend 2' then :blue
            when 'Backend 3' then :yellow
            else :pink
            end
    load_indicator = load == 'high' ? '🔥' : '✓'
    puts "Requisição #{num.to_s.rjust(3)}: #{server_id.send(color)} #{load_indicator}"
  end

  def print_summary
    distribution = @responses.group_by { |r| r[:id] }
    total = @responses.size
    duration = Time.now - @start_time
    success_rate = (@responses.size.to_f / @requests * 100).round(2)

    puts "\n#{'='.blue * 40}"
    puts "📊 #{'RESUMO DO TESTE'.green}"
    puts "#{'='.blue * 40}"

    puts "\n⚙️  #{'Configuração:'.pink}"
    puts "   Algoritmo: #{@algorithm}"
    puts "   Total de requisições: #{@requests}"
    puts "   Modo de falha: #{@test_failures ? 'Ativo' : 'Inativo'}"

    puts "\n📈 #{'Resultados:'.pink}"
    puts "   Duração total: #{duration.round(2)} segundos"
    puts "   Taxa de sucesso: #{success_rate}%"
    puts "   Erros: #{@errors.size}"

    puts "\n📊 #{'Distribuição por carga:'.yellow}"

    max_requests = distribution.values.map(&:size).max

    distribution.each do |server, requests|
      high_load = requests.count { |r| r[:load] == 'high' }
      percentage = (requests.size.to_f / total * 100).round(1)

      filled = ((requests.size.to_f / max_requests) * BAR_WIDTH).round
      empty = BAR_WIDTH - filled

      color = case server
              when 'Backend 1' then :green
              when 'Backend 2' then :blue
              when 'Backend 3' then :yellow
              else :pink
              end

      puts "\n#{server.send(color)}: #{requests.size} requisições (#{percentage}%)"
      puts "   - Carga alta: #{high_load} requisições"
      puts "   - Carga normal: #{requests.size - high_load} requisições"

      bar = '█' * filled + '░' * empty
      puts "[#{bar.send(color)}] #{percentage}%"
    end

    if @errors.any?
      puts "\n❌ #{'Erros encontrados:'.red}"
      @errors.each.with_index(1) do |error, i|
        puts "  #{i}. #{error.message}"
      end
    end

    puts "\n#{'='.blue * 40}"
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Uso: ruby load_balancer_tester.rb [opções]'

  opts.on('-a', '--algorithm ALGORITHM',
          'Algoritmo de balanceamento (round-robin, least-conn, ip-hash, weighted)') do |a|
    options[:algorithm] = a
  end

  opts.on('-r', '--requests NUM', Integer, 'Número de requisições') do |n|
    options[:requests] = n
  end

  opts.on('-f', '--[no-]test-failures', 'Testar com simulação de falhas') do |f|
    options[:test_failures] = f
  end

  opts.on('-h', '--help', 'Mostra esta mensagem') do
    puts opts
    exit
  end
end.parse!

LoadBalancerTest.new(options).run
