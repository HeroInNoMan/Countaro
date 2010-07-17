#!/usr/bin/ruby

LARGEUR_LIGNE = 10
NB_JOUEURS = 5
BASE_CONTRAT = 25
BASE_ENC = 50

class Partie
  attr_accessor :joueurs,:manches

  def initialize
    @joueurs = Array.new(NB_JOUEURS)
    @manches = Array.new(0)
    puts "Nouvelle partie !"
    @joueurs.each_index do |i|
      puts "Nom du joueur #{i+1} :"
      @joueurs[i] = gets.chomp
    end
  end
  
  def nouvelle_manche
    contrat = prompt_contrat
    if(contrat =~ /^e$/i )
      p1 = prompt_preneur(0)
    else
      marge = prompt_marge
      p1 = prompt_preneur(1)
      p2 = prompt_preneur(2)
    end
    @manches.push(Manche.new(contrat, marge, p1, p2))
  end
  
  def afficher_scores
    scores = "Scores :\n"
    @joueurs.each do |joueur|
      (LARGEUR_LIGNE - joueur.length).times do scores << " " end
      scores << joueur
      scores << "|"
    end
    scores << "\n"
    @manches.each do |manche|
      scores << manche.to_string
    end
    scores << "\n"
    puts scores
  end
  
  def modif_nom_joueur
    puts "Modifier le nom du joueur : "
    compteur = 1
    @joueurs.each do |joueur|
      print "#{compteur} : #{joueur.to_s} | "
      compteur += 1
    end
    print "\n"
    num_joueur = gets.chomp
    if num_joueur =~ /^[12345]$/
      puts "Nouveau nom pour " + @joueurs[Integer(num_joueur)-1] + " :"
      @joueurs[Integer(num_joueur)-1] = gets.chomp
      puts "Ok !"
    else
      puts "Saisie non valide !"
      modif_nom_joueur
    end
  end
end

class Manche
  attr_accessor :values,:contrat,:bonus,:p1,:p2
  
  def initialize(_contrat, _marge, _p1, _p2)
    @values = Array.new(NB_JOUEURS, 0)
    @contrat = _contrat
    @marge = _marge
    @bonus = ""
    @p1 = Integer(_p1)
    @p2 = Integer(_p2)
    calculer_scores
  end

  def add(num_joueur, score)
    values[num_joueur] += score
  end
  
  def to_string
    score_manche = ""
    values.each do |value|
      (LARGEUR_LIGNE - value.to_s.length).times do score_manche << " " end
      score_manche << "#{value}|"
    end
    score_manche << " #{@contrat.upcase}"
    score_manche << "(#{@marge})" unless @contrat =~ /^e$/i
    score_manche << @bonus
    score_manche << "\n"
    return score_manche
  end
  
  def calculer_scores
    case @contrat
    when /^p$/i
      m = 1
    when /^g$/i
      m = 2
    when /^gs$/i
      m = 4
    when /^gc$/i
      m = 6
    when /^e$/i
      m = 1
      @p2 = @p1
      @marge = -25
    end
    if(@marge == "-0")
      base = -m * BASE_CONTRAT
    else
      @marge = Integer(@marge)
      base = m * (BASE_CONTRAT + @marge.abs)
      if (@marge < 0)
        base = -base
      end
    end
    @values.each_index do |i|
      unless($partie.manches.size == 0)
        add(i, $partie.manches.last.values[i])
      end
      if(i == @p1 - 1 and i == @p2 - 1)
        add(i, 4 * base)
      elsif(i == @p1 - 1)
        add(i, 2 * base)
      elsif(i == @p2 - 1)
        add(i, base)
      else
        add(i, -base)
      end
    end
  end
  
  def ajouter_bonus
    bonus = prompt_bonus
    case bonus
    when /^p$/i
      p = prompt_preneur(1)
      calculer_bonus(20, p)
      nom = "poignée"
    when /^2p$/i
      p = prompt_preneur(1)
      calculer_bonus(30, p)
      nom = "double poignée"
    when /^3p$/i
      p = prompt_preneur(1)
      calculer_bonus(40, p)
      nom = "triple poignée"
    when /^m$/i
      p = prompt_preneur(1)
      calculer_bonus(10, p)
      nom = "misère"
    when /^2m$/i
      p = prompt_preneur(1)
      calculer_bonus(20, p)
      nom = "double misère"
    when /^pb$/i
      calculer_petit_au_bout
      nom = "petit au bout"
    end
    @bonus << " + " + nom
    if(p)
      @bonus << "(" + $partie.joueurs[Integer(p)-1] + ")"
    end
  end

  def calculer_petit_au_bout
    case @contrat
    when /^p$/i
      m = 1
    when /^g$/i
      m = 2
    when /^gs$/i
      m = 4
    when /^gc$/i
      m = 6
    end
    valeur = 10 * m
    nom = "petit au bout"
    puts "1 : Pris par l'attaque | 2 : pris par la défense |"
    gagne_perdu = gets.chomp
    case gagne_perdu
    when /^1$/
    when /^2$/
      valeur = -valeur
    else
      "Saisie non valide."
      calculer_petit_au_bout
    end
    @values.each_index do |i|
      if(i == @p1 - 1)
        add(i, valeur * 2)
      elsif (i == @p2 - 1)
        add(i, valeur)
      else
        add(i, -valeur)
      end
    end
  end
  
  def calculer_bonus(bonus, p)
    @values.each_index do |i|
      if(i == (Integer(p) - 1))
        add(i, bonus * 4)
      else
        add(i, -bonus)
      end
    end
  end
end

def prompt_contrat
  puts "Contrat : (p = petite | g = garde | gs = garde sans | gc = garde contre | e = enculette)"
  contrat = gets.chomp
  if contrat =~ /^(p|g|gs|gc|e)$/i
    return contrat
  end
  puts "Saisie non valide !"
  prompt_contrat
end

def prompt_marge
  puts "Fait de : (négatif si chuté)"
  marge = gets.chomp
  if marge =~ /^\-?\d+$/
    return marge
  end
  puts "Saisie non valide !"
  prompt_marge
end

def prompt_preneur(numero)
  case numero
  when 0
    print "Victime : ("
  when 1
    print "Pris par : ("
  when 2
    print "Aidé par : ("
  end
  compteur = 1
  $partie.joueurs.each do |joueur|
    print "#{compteur} : #{joueur.to_s} | "
    compteur += 1
  end
  print ")\n"
  preneur = gets.chomp
  if preneur =~ /^[12345]$/
    return preneur
  end
  puts "Saisie non valide !"
  prompt_preneur(numero)
end

def prompt_bonus
  puts "p = poignée | 2p = double poignée | 3p = triple poignée | m = misère | 2m = double misère | pb = petit au bout"
  bonus = gets.chomp
  if bonus =~ /^(p|2p|3p|m|2m|pb)$/i
    return bonus
  end
  puts "Saisie non valide !"
  prompt_bonus
end

def wait_for_command
  puts "n = nouvelle manche | a = ajouter un bonus | h = afficher l'aide | q = quitter"
  command = gets.chomp
  case command
  when /^h(elp)?$/i
    puts "h = afficher cette page d'aide"
    puts "n = nouvelle manche"
    puts "a = ajouter un bonus à la manche précédente"
    puts "l = lister les scores"
    puts "m = modifier le nom d'un joueur"
    puts "s = supprimer la dernière ligne"
    puts "q = quitter"
  when /^a$/i
    if $partie == nil or $partie.manches.size == 0
      puts "Enregistrer une manche."
    else
      $partie.manches.last.ajouter_bonus
      $partie.afficher_scores
    end
  when /^l(ist(e)?)?$/i
    if $partie == nil
      puts "Créer une partie d'abord."
    else
      $partie.afficher_scores
    end
  when /^n$/i
    if $partie == nil
      $partie = Partie.new
    end
      $partie.nouvelle_manche
      $partie.afficher_scores
  when /^p$/i
    $partie = Partie.new
  when /^s$/i
    if $partie == nil
      puts "Créer une partie d'abord."
    else
      $partie.manches.delete_at(($partie.manches.size) - 1)
      $partie.afficher_scores
    end
  when /^m$/i
    if $partie == nil
      puts "Créer une partie d'abord."
    else
      $partie.modif_nom_joueur
    end
  when /^(q|exit|quit|bye)$/i
    Process.exit
  else
    puts "Commande non valide."
  end
  wait_for_command
end
puts "****************************************"
puts "**** Calculateur de points de tarot ****"
puts "****************************************"
puts "\n\n\n"
wait_for_command

#EOF
