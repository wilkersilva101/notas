# frozen_string_literal: true

namespace :regras do
  desc 'Gera relatório HTML de aderência às regras de negócio'
  task report: :environment do
    require 'erb'

    regras_file = Rails.root.join('REGRAS_NEGOCIO.md')
    
    unless File.exist?(regras_file)
      puts "Arquivo REGRAS_NEGOCIO.md não encontrado!"
      exit 1
    end

    content = File.read(regras_file)
    
    # Parser simples para extrair regras
    categorias = parse_regras(content)
    
    # Gera HTML
    html = generate_html(categorias)
    
    # Salva arquivo
    output_file = Rails.root.join('regras_negocio_report.html')
    File.write(output_file, html)
    
    puts "Relatório gerado: #{output_file}"
    puts "Abra no navegador: xdg-open #{output_file}"
  end

  def parse_regras(content)
    categorias = []
    categoria_atual = nil
    
    content.each_line do |line|
      # Detecta headers de categoria (### 1. Autenticação)
      if line =~ /^###\s*\d+\.\s*(.+)$/
        categoria_atual = {
          nome: $1.strip,
          regras: []
        }
        categorias << categoria_atual
      end
      
      # Detecta linhas de regras na tabela
      if categoria_atual && line =~ /^\|\s*(.+?)\s*\|\s*([✅⚠️❌])\s*\|/
        regra = $1.strip
        status = $2
        categoria_atual[:regras] << { nome: regra, status: status }
      end
    end
    
    categorias
  end

  def generate_html(categorias)
    total_regras = 0
    total_cobertas = 0
    
    categorias_html = categorias.map do |cat|
      regras_count = cat[:regras].size
      cobertas = cat[:regras].count { |r| r[:status] == '✅' }
      parciais = cat[:regras].count { |r| r[:status] == '⚠️' }
      nao_cobertas = cat[:regras].count { |r| r[:status] == '❌' }
      
      total_regras += regras_count
      total_cobertas += cobertas
      
      porcentagem = regras_count > 0 ? (cobertas.to_f / regras_count * 100).round(1) : 0
      cor = porcentagem >= 80 ? '#10b981' : porcentagem >= 50 ? '#f59e0b' : '#ef4444'
      
      regras_rows = cat[:regras].map do |regra|
        status_class = case regra[:status]
                       when '✅' then 'status-ok'
                       when '⚠️' then 'status-warning'
                       when '❌' then 'status-error'
                       end
        status_text = case regra[:status]
                      when '✅' then 'Coberto'
                      when '⚠️' then 'Parcial'
                      when '❌' then 'Não Coberto'
                      end
        <<~ROW
          <tr>
            <td class="regra-nome">#{escape_html(regra[:nome])}</td>
            <td class="status #{status_class}">#{regra[:status]} #{status_text}</td>
          </tr>
        ROW
      end.join

      <<~CAT
        <div class="categoria">
          <div class="categoria-header">
            <h2>#{escape_html(cat[:nome])}</h2>
            <div class="progress-container">
              <div class="progress-bar" style="width: #{porcentagem}%; background: #{cor};"></div>
              <span class="progress-text">#{porcentagem}% (#{cobertas}/#{regras_count})</span>
            </div>
          </div>
          <div class="stats">
            <span class="stat ok">✅ #{cobertas}</span>
            <span class="stat warning">⚠️ #{parciais}</span>
            <span class="stat error">❌ #{nao_cobertas}</span>
          </div>
          <table class="regras-table">
            <thead>
              <tr>
                <th>Regra</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              #{regras_rows}
            </tbody>
          </table>
        </div>
      CAT
    end.join

    geral_porcentagem = total_regras > 0 ? (total_cobertas.to_f / total_regras * 100).round(1) : 0
    geral_cor = geral_porcentagem >= 80 ? '#10b981' : geral_porcentagem >= 50 ? '#f59e0b' : '#ef4444'

    <<~HTML
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Relatório de Regras de Negócio</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
          }
          
          .container {
            max-width: 1200px;
            margin: 0 auto;
          }
          
          header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
          }
          
          h1 {
            color: #1a1a2e;
            font-size: 2rem;
            margin-bottom: 20px;
          }
          
          .summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
          }
          
          .summary h2 {
            font-size: 3rem;
            margin-bottom: 10px;
          }
          
          .summary p {
            font-size: 1.1rem;
            opacity: 0.9;
          }
          
          .categoria {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            overflow: hidden;
          }
          
          .categoria-header {
            background: #f8f9fa;
            padding: 20px 25px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
          }
          
          .categoria-header h2 {
            color: #1a1a2e;
            font-size: 1.3rem;
          }
          
          .progress-container {
            display: flex;
            align-items: center;
            gap: 15px;
            min-width: 200px;
          }
          
          .progress-bar {
            height: 20px;
            border-radius: 10px;
            transition: width 0.3s ease;
            flex: 1;
          }
          
          .progress-text {
            font-weight: 600;
            color: #495057;
            min-width: 80px;
            text-align: right;
          }
          
          .stats {
            display: flex;
            gap: 20px;
            padding: 15px 25px;
            background: #f8f9fa;
          }
          
          .stat {
            font-weight: 500;
          }
          
          .stat.ok { color: #10b981; }
          .stat.warning { color: #f59e0b; }
          .stat.error { color: #ef4444; }
          
          .regras-table {
            width: 100%;
            border-collapse: collapse;
          }
          
          .regras-table th {
            text-align: left;
            padding: 15px 25px;
            background: #f8f9fa;
            color: #6c757d;
            font-weight: 600;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }
          
          .regras-table td {
            padding: 15px 25px;
            border-bottom: 1px solid #e9ecef;
          }
          
          .regras-table tr:last-child td {
            border-bottom: none;
          }
          
          .regra-nome {
            color: #333;
          }
          
          .status {
            font-weight: 500;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
          }
          
          .status-ok {
            background: #d1fae5;
            color: #065f46;
          }
          
          .status-warning {
            background: #fef3c7;
            color: #92400e;
          }
          
          .status-error {
            background: #fee2e2;
            color: #991b1b;
          }
          
          .footer {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-size: 0.9rem;
          }
          
          @media (max-width: 768px) {
            .categoria-header {
              flex-direction: column;
              align-items: flex-start;
            }
            
            .progress-container {
              width: 100%;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <h1>📋 Relatório de Regras de Negócio</h1>
            <div class="summary" style="background: #{geral_cor}; background: linear-gradient(135deg, #{geral_cor} 0%, #{darken_color(geral_cor)} 100%);">
              <h2>#{geral_porcentagem}%</h2>
              <p>#{total_cobertas} de #{total_regras} regras totalmente cobertas</p>
              <p style="margin-top: 10px; font-size: 0.9rem;">Gerado em: #{Time.current.strftime('%d/%m/%Y %H:%M')}</p>
            </div>
          </header>
          
          <main>
            #{categorias_html}
          </main>
          
          <footer class="footer">
            <p>PostsController - Aderência às Regras de Negócio</p>
          </footer>
        </div>
      </body>
      </html>
    HTML
  end

  def escape_html(text)
    text.gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
        .gsub('"', '&quot;')
  end

  def darken_color(hex)
    # Simples escurecimento de cor para gradiente
    hex.gsub('#', '').scan(/../).map { |c| (c.to_i(16) * 0.8).to_i.to_s(16).rjust(2, '0') }.join.prepend('#')
  end
end
