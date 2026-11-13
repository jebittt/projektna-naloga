function narisiMrezo(mesh,path)
xy = mesh.xy*1000;
f = figure('Visible','off','Color','w','Position',[50 50 1100 700]);
cleanup = onCleanup(@() close(f));
ax = axes(f);
patch(ax,'Vertices',xy,'Faces',double(mesh.cells),'FaceColor',[.97 .98 .99], ...
    'EdgeColor',[.76 .79 .82],'LineWidth',0.25);
hold(ax,'on');
names = {'Vstopni rob','Tlačna stran','Sesalna stran','Hladilni kanali'};
colors = [.73 .17 .10;.82 .43 .02;.46 .23 .65;.02 .40 .61];
h = gobjects(4,1);
for g = 1:numel(mesh.bc)
    bc = mesh.bc(g);
    id = bc.id;
    h(id) = plot(ax,xy(bc.nodes,1),xy(bc.nodes,2),'.','MarkerSize',7, ...
        'Color',colors(id,:),'DisplayName',sprintf('%s  |  %g °C,  h = %g',names{id},bc.value,bc.h));
end
axis(ax,'equal');
xlim(ax,[min(xy(:,1))-0.6 max(xy(:,1))+0.6]);
ylim(ax,[min(xy(:,2))-0.6 max(xy(:,2))+0.8]);
xlabel(ax,'x [mm]'); ylabel(ax,'y [mm]');
title(ax,'Prerez hlajene lopatice in robni pogoji');
lg = legend(ax,h,'Location','southoutside','NumColumns',2);
title(lg,'Temperatura okolice in prestopnost h [W/(m² K)]');
exportgraphics(f,path,'Resolution',300);
end
