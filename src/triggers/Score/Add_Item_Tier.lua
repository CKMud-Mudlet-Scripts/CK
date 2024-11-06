local API = CK.API

echo("\n")
cecho(string.format('<dim_gray>PHY DAM<white>:         <yellow>%-18s<dim_gray>KI DAM<white>:    <yellow>%s\n',
    CK.math.format(API:phy_dam()), CK.math.format(API:ki_dam())))
cecho(string.format('<dim_gray>PHY DAM(B)<white>:      <yellow>%-18s<dim_gray>KI DAM(B)<white>: <yellow>%s\n',
    CK.math.format(API:phy_dam(false, true)), CK.math.format(API:ki_dam(false, true))))
cecho(string.format('<dim_gray>PHY DAM(S)<white>:      <yellow>%-18s<dim_gray>KI DAM(S)<white>: <yellow>%s\n',
    CK.math.format(API:phy_dam(true)), CK.math.format(API:ki_dam(true))))
cecho(string.format('<dim_gray>PHY DAM(U)<white>:      <yellow>%-18s<dim_gray>KI DAM(U)<white>: <yellow>%s\n',
    CK.math.format(API:phy_dam(true, true, true)), CK.math.format(API:ki_dam(true, true, true))))
cecho(string.format('<dim_gray>Item Tier<white>: <green>%7s\n', API:item_tier()))
