{
    description = "sup";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        catppuccin.url = "github:catppuccin/nix";
	lazyvim.url = "github:pfassina/lazyvim-nix";
        #sops-nix = {
        #    url = "github:Mic92/sops-nix";
	#    inputs.nixpkgs.follows = "nixpkgs";
	#};
    };
    
    outputs = { self, nixpkgs, home-manager, catppuccin, lazyvim, ... }: {
        nixosConfigurations.tuna = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
   	    modules = [
                ./configuration.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.twm = {
			  imports = [ 
			    ./home.nix
			    catppuccin.homeModules.catppuccin
			    lazyvim.homeManagerModules.default
			    #sops-nix.nixosModules.sops
			  ];
                        };
			backupFileExtension = "backup";  
                    };
                }
		catppuccin.nixosModules.catppuccin
	    ];
        };  
    };
}

