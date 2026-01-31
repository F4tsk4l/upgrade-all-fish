function upgrade-all
    function show_help
        echo "Usage:"
        echo "  upgrade-all -A    Perform full upgrade (Pacman, Yay, Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
        echo "  upgrade-all -a    Perform partial upgrade (Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
        echo "  upgrade-all -h    Display this help message"
    end

    if set -q argv[1]
        switch "$argv[1]"
            case -A
                echo "Full upgrade selected (Pacman, Yay, Ya(Yazi), Cargo, Nvim_Plugins, Pipx, Fisher)"
                sudo pacman -Syudd --noconfirm
                #yay -Suadd --sudoloop --cleanafter --answeredit None --answerdiff None --answerclean None --save
                and yay -Sua
                and ya pkg upgrade
                and nvim --headless "+Lazy! update" +qa
                and cargo install-update -a
                and pipx upgrade-all
                and fisher update
            case -a
                echo "Partial upgrade selected (Ya(Yazi), Fisher, Cargo, Nvim_Plugins, Pipx)"
                ya pkg upgrade
                and fisher update
                and cargo install-update -a
                and nvim --headless "+Lazy! update" +qa
                and pipx upgrade-all
            case -h
                show_help
                return 0
            case '*'
                echo "Invalid option. Use -h for help."
                return 1
        end
    else
        echo "No option provided. Use -h for help."
        return 1
    end
end
