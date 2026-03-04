import 'package:flutter/material.dart';

import '../viewmodel/aula_acessibilidade_view_model.dart';

// =============================================================================
// AULA — ACESSIBILIDADE (View em MVVM)
// =============================================================================
// Aqui vocês vão ver uma página de perfil feita com foco em
// acessibilidade: contraste de cores (4,5:1), Semantics para leitores de tela
// e uma estrutura que ajuda quem usa tecnologias assistivas. Leiam os
// comentários junto com o código — foi pensado pra vocês acompanharem na aula.
// O ViewModel (mostrarRaioX, callback) vem do app; a View só monta a UI.
// =============================================================================

class AulaAcessibilidadePage extends StatelessWidget {
  const AulaAcessibilidadePage({super.key, required this.viewModel});

  final AulaAcessibilidadeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final mostrarRaioX = viewModel.mostrarRaioX;
    final aoAlternarRaioX = viewModel.aoAlternarRaioX;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aula — Acessibilidade'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Controle do Raio-X no AppBar: assim ele não some quando o debug
          // liga (o overlay costuma cobrir o body, mas o AppBar fica acessível).
          IconButton(
            icon: Icon(
              mostrarRaioX ? Icons.accessibility : Icons.accessibility_new,
            ),
            tooltip: mostrarRaioX ? 'Desligar Raio-X' : 'Ligar Raio-X',
            onPressed: () => aoAlternarRaioX(!mostrarRaioX),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -----------------------------------------------------------------
            // 1) CONTRASTE DE CORES (WCAG 4,5:1)
            // -----------------------------------------------------------------
            // A WCAG pede no mínimo 4,5:1 de contraste entre texto e fundo
            // (3:1 pra texto grande). Aqui a gente usa texto escuro (grey[900])
            // em fundo claro — assim passa tranquilo. Não usem cinza claro
            // (grey[400] ou mais claro) em fundo branco; quem tem baixa visão
            // não consegue ler.
            // -----------------------------------------------------------------

            // -----------------------------------------------------------------
            // 2) SEMÂNTICA NA IMAGEM (avatar)
            // -----------------------------------------------------------------
            // O TalkBack (Android) e o VoiceOver (iOS) leem a "árvore de
            // semântica" do Flutter. Se a gente não colocar label, eles só
            // falam "imagem". Com o label abaixo, quem não enxerga ouve
            // "Foto de perfil de Maria Silva". Sempre descrevam o que a
            // imagem representa, não só "imagem".
            // -----------------------------------------------------------------
            Semantics(
              label: 'Foto de perfil de Maria Silva',
              image: true,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.indigo.shade100,
                child: Icon(
                  Icons.person,
                  size: 56,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // header: true diz pro leitor de tela que isso é um título/cabeçalho;
            // assim o usuário pode pular de seção em seção sem ouvir tudo de novo.
            Semantics(
              label: 'Nome do usuário',
              header: true,
              child: Text(
                'Maria Silva',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // -----------------------------------------------------------------
            // 3) TEXTO COM BOM CONTRASTE
            // -----------------------------------------------------------------
            // grey[700] em fundo claro ainda passa no 4,5:1. Quando forem
            // fazer seus apps, evitem grey[400] ou mais claro pro texto
            // principal — não passa no teste e prejudica muita gente.
            // -----------------------------------------------------------------
            Text(
              'maria.silva@email.com',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 32),

            // -----------------------------------------------------------------
            // 4) REGIÕES SEMÂNTICAS (agrupamento lógico)
            // -----------------------------------------------------------------
            // container: true agrupa tudo que está dentro numa "região".
            // O leitor de tela anuncia o label e o usuário pode navegar
            // por blocos (ex.: "Informações do perfil") em vez de item
            // por item. Deixa a navegação muito mais rápida.
            // -----------------------------------------------------------------
            Semantics(
              container: true,
              label: 'Informações do perfil',
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PerfilRow(
                        icon: Icons.badge_outlined,
                        label: 'Cargo',
                        value: 'Desenvolvedora Mobile',
                      ),
                      const Divider(height: 24),
                      _PerfilRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        value: '(11) 98765-4321',
                      ),
                      const Divider(height: 24),
                      _PerfilRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Membro desde',
                        value: 'Jan/2024',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // 5) EXCLUDE SEMANTICS E MERGE SEMANTICS
            // -----------------------------------------------------------------
            // ExcludeSemantics: esconde do leitor de tela (ex.: ícone decorativo).
            // MergeSemantics: junta o título e o "botão" num bloco só — senão
            // ele lê "Configurações Avançadas" e depois "botão". Com o Raio-X
            // ligado, vocês veem que vira uma caixa única.
            // -----------------------------------------------------------------
            MergeSemantics(
              child: ListTile(
                leading: const ExcludeSemantics(child: Icon(Icons.settings)),
                title: const Text('Configurações Avançadas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // 6) BOTÃO ACESSÍVEL (área de toque mínima 48x48)
            // -----------------------------------------------------------------
            // A WCAG recomenda pelo menos 48px de altura/largura pra área
            // clicável. ConstrainedBox garante isso. O label descreve a ação
            // pro leitor de tela.
            // -----------------------------------------------------------------
            Semantics(
              button: true,
              label: 'Editar perfil',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // -----------------------------------------------------------------
            // 7) EXEMPLO DE MAL CONTRASTE (o que NÃO fazer)
            // -----------------------------------------------------------------
            // Este bloco de propósito tem contraste ruim: texto claro em
            // fundo claro. Em produção isso prejudica quem tem baixa visão,
            // daltonismo ou usa o celular no sol. Não façam isso nos
            // projetos de vocês.
            // -----------------------------------------------------------------
            Semantics(
              container: true,
              label:
                  'Exemplo de texto com contraste ruim — não use em produção',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Evite texto amarelo claro em fundo claro: contraste < 4,5:1.',
                        style: TextStyle(
                          color: Colors.amber.shade200,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resumo pro aluno: o bloco acima é didático; em produção usem
            // cores que passem no 4,5:1. Ferramentas como WebAIM Contrast
            // Checker ajudam a testar.
            Text(
              'O bloco acima tem contraste ruim de propósito. Nos seus apps, usem cores que passem no teste 4,5:1 (ex.: WebAIM Contrast Checker).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _PerfilRow: uma linha do card (ícone + label + valor).
//
// Sem o que a gente fez aqui embaixo, o leitor de tela leria o label e o valor
// em nós separados — por exemplo "Cargo" e depois "Desenvolvedora Mobile".
// Para soar natural, queremos uma frase só: "Cargo: Desenvolvedora Mobile".
//
// Por isso envolvemos a Row em MergeSemantics (junta os nós em um) e
// Semantics(label: '$label: $value') (define o texto único que será lido).
// O ícone e os textos visuais ficam em ExcludeSemantics para não serem
// anunciados de novo — o leitor só ouve o label que a gente definiu.
// -----------------------------------------------------------------------------
class _PerfilRow extends StatelessWidget {
  const _PerfilRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: '$label: $value',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 22, color: Colors.grey.shade900),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
