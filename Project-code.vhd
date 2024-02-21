library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

-- arch project_reti_logiche
architecture project_reti_logiche_arch of project_reti_logiche is

-- lista segnali project_reti_logiche_arch
-- dichiarazione stati FSM   
type S is (PRIMO_BIT, SECONDO_BIT, N_BIT, INDIRIZZO_MEM, ATTESA, SELEZIONE, OUTPUT, FINAL);
signal curr_state : S;

-- segnali utilizzati per salvare
signal bit_reg : std_logic_vector(1 downto 0) := (others => '0'); -- vettore di due bit per decidere il canale di uscita
signal n_bit_reg : std_logic_vector(15 downto 0) := (others => '0'); -- vettore per salvare indirizzo da dare alla memoria
signal z0_bit_reg : std_logic_vector(7 downto 0):= (others => '0'); -- segnale dove salvo i risultati di z0
signal z1_bit_reg : std_logic_vector(7 downto 0):= (others => '0'); -- segnale dove salvo i risultati di z1
signal z2_bit_reg : std_logic_vector(7 downto 0):= (others => '0'); -- segnale dove salvo i risultati di z2
signal z3_bit_reg : std_logic_vector(7 downto 0):= (others => '0'); -- segnale dove salvo i risultati di z3

-- segnali speciali
signal inizio : std_logic := '1'; -- segnale utilizzato solo inizialmente per evitare undefined in enable

-- inizio project_reti_logiche_arch
begin

process(i_clk, i_rst)
begin

if i_rst = '1' or inizio = '1' then -- segnale RESET ripristina i segnali e INIZIO inizializza i segnali

-- ripristiniamo tutti i segnali e impostiamo stato iniziale 
    o_mem_en <= '0'; 
    o_mem_we <= '0'; 
    o_done <= '0';        
    o_mem_addr <= "0000000000000000"; 
    inizio <= '0';  
    o_z0 <= "00000000";
    o_z1 <= "00000000";
    o_z2 <= "00000000";
    o_z3 <= "00000000";
    z0_bit_reg <= "00000000";
    z1_bit_reg <= "00000000";
    z2_bit_reg <= "00000000";
    z3_bit_reg <= "00000000";
    bit_reg <= "00";
    n_bit_reg <= "0000000000000000";
    curr_state <= PRIMO_BIT;

elsif i_clk'event and i_clk = '1' then

-- leggiamo il PRIMO bit che verrà concatenato con l'ultimo bit del vettore bit_reg
    if curr_state = PRIMO_BIT then
        if i_start = '1' then
            o_mem_en <= '1';
            o_mem_we <= '0';
            o_done <= '0';
            o_mem_addr <= "0000000000000000";
            bit_reg <= bit_reg(0 downto 0) & i_w;
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            n_bit_reg <= "0000000000000000";
            inizio <= '0'; 
            curr_state <= SECONDO_BIT;
        else -- aspettiamo che i_start diventi 1
            inizio <= '0'; 
            curr_state <= PRIMO_BIT;           
        end if;
    end if;    
 
-- leggiamo il SECONDO bit che verrà concatenato con l'ultimo bit del vettore bit_reg
-- Otteniamo il vettore completo che indica il camale di output     
    if curr_state = SECONDO_BIT then
        if i_start = '1' then
            o_mem_en <= '1';
            o_mem_we <= '0';
            o_done <= '0';
            o_mem_addr <= "0000000000000000";
            bit_reg <= bit_reg(0 downto 0) & i_w;
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            inizio <= '0'; 
            curr_state <= N_BIT;
        end if;
    end if;    

-- Leggiamo N bit per indirizzo memoria, restiamo in questo stato finchè i_start = 1
-- Otteniamo il vettore n_bit_reg completo
-- Passiamo allo stato successivo se i_start = 0    
    if curr_state = N_BIT then
        if i_start = '1' then
            o_mem_en <= '1';
            o_mem_we <= '0';
            o_done <= '0';
            o_mem_addr <= "0000000000000000";
            n_bit_reg <= n_bit_reg(14 downto 0) & i_w;
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            inizio <= '0'; 
            curr_state <= N_BIT;
        else
            inizio <= '0'; 
            curr_state <= INDIRIZZO_MEM;
        end if;
    end if; 

-- L'indirizzo di memoria passa da 0000000000000000 a n_bit_reg
    if curr_state = INDIRIZZO_MEM then
        o_mem_en <= '1';
        o_mem_we <= '0';
        o_done <= '0';
        o_mem_addr <= n_bit_reg;
        o_z0 <= "00000000";
        o_z1 <= "00000000";
        o_z2 <= "00000000";
        o_z3 <= "00000000";
        inizio <= '0'; 
        curr_state <= ATTESA;
    end if; 

-- aspetto ciclo di i_clk per ricevere dato dalla memoria     
    if curr_state = ATTESA then
        o_mem_en <= '1';
        o_mem_we <= '0';
        o_done <= '0';
        o_mem_addr <= n_bit_reg;
        o_z0 <= "00000000";
        o_z1 <= "00000000";
        o_z2 <= "00000000";
        o_z3 <= "00000000";
        inizio <= '0'; 
        curr_state <= SELEZIONE;
    end if;  

-- inserisco il dato della memoria nel canale tramite la selezione fatta con bit_reg 
   if curr_state = SELEZIONE then
        o_mem_en <= '1';
        o_mem_we <= '0';
        o_done <= '0';
        o_z0 <= "00000000";
        o_z1 <= "00000000";
        o_z2 <= "00000000";
        o_z3 <= "00000000";
        inizio <= '0'; 
        o_mem_addr <= n_bit_reg;
        if (bit_reg = "00") then
            z0_bit_reg <= i_mem_data; 
        
        elsif (bit_reg = "01") then
            z1_bit_reg <= i_mem_data;
         
        elsif (bit_reg = "10") then
            z2_bit_reg <= i_mem_data;
         
        elsif (bit_reg = "11") then
            z3_bit_reg <= i_mem_data;
        end if;
        curr_state <= OUTPUT;
    end if;        

-- alzo o_done a 1 e stampiamo i valori salvati nei canali     
    if curr_state = OUTPUT then
        o_mem_en <= '1';
        o_mem_we <= '0';
        o_done <= '1';
        o_mem_addr <= n_bit_reg;
        o_z0 <= z0_bit_reg;
        o_z1 <= z1_bit_reg;
        o_z2 <= z2_bit_reg;
        o_z3 <= z3_bit_reg;
        inizio <= '0';  
        curr_state <= FINAL;
    end if; 
     
-- Aspettiamo un ciclo di i_clk prima di inziiare a leggere subito un nuovo input
-- Sistemiamo i segnali     
    if curr_state = FINAL then
        o_mem_en <= '1';
        o_mem_we <= '0';
        o_done <= '0';
        o_mem_addr <= n_bit_reg;
        o_z0 <= "00000000";
        o_z1 <= "00000000";
        o_z2 <= "00000000";
        o_z3 <= "00000000";
        inizio <= '0'; 
        curr_state <= PRIMO_BIT;
    end if;  

end if; -- fine i_clk'event and i_clk = '1'  

inizio <= '0';      

end process; -- fine processo

end project_reti_logiche_arch;
