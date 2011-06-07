
% to generate these files, use these queries on a database generated from
% log_to_db.py
%
% -- queries for generating the per-meeting timeline charts
% select id, meeting_id, unix_timestamp(created), shared, likes, length(text), created_by_actor_id
%     INTO OUTFILE '/tmp/ideas.csv'
%          FIELDS TERMINATED BY '\t'
%          LINES TERMINATED BY '\n'
%     from tasks
%     where ;
% 
% 
% select id, meeting_id, unix_timestamp(created), unix_timestamp(started),unix_timestamp(stopped)
%     INTO OUTFILE '/tmp/topics.csv'
%          FIELDS TERMINATED BY '\t'
%          LINES TERMINATED BY '\n'
%     from topics;
% 
% 
% select id, unix_timestamp(started),unix_timestamp(stopped)
%     INTO OUTFILE '/tmp/meetings.csv'
%          FIELDS TERMINATED BY '\t'
%          LINES TERMINATED BY '\n'
%     from meetings;

ideas = importdata('ideas.csv', '\t');
topics = importdata('topics.csv', '\t');
meetings = importdata('meetings.csv', '\t');

meeting_ids = unique(ideas(:, 2));
figure
i=1;
for meeting_id=meeting_ids'
    subplot(size(meeting_ids, 1),1, i);
    
    start_time = meetings(find(meetings(:, 1)==meeting_id), 2);
    stop_time = meetings(find(meetings(:, 1)==meeting_id), 3);
    
    meeting_topics = topics(find(topics(:, 2)==meeting_id), :);
    
    idea_creation_times = ideas(find(ideas(:, 2)==meeting_id), :);
    
    last_idea = max(idea_creation_times(:, 3));
    first_idea=min(idea_creation_times(:, 3));
    
    sprintf('%d -> %d ; %d -> %d', start_time, stop_time, first_idea, last_idea)
    
     created_by_professor = idea_creation_times(find(idea_creation_times(:, 7)==2), 3);
    
     created_by_students = idea_creation_times(find(idea_creation_times(:, 7)~=2), 3);
    
   for idea = idea_creation_times'
       % for each one, the x position is 
       time = (idea(3)-start_time)/60;
       height_factor = (idea(6)/200)*0.5+0.1;
       if(height_factor > 0.6)
           height_factor = 0.6;
       end
       
       if(idea(7)==2)
           color='r';
       else
           color='k';
       end
%       h = line([time time], [-1 (1-height_factor)*-1]);
      h = line([time time], [height_factor -height_factor]);
      set(h, 'Color', color);
      set(h, 'LineWidth', 1);
   end
     
%       h = plot((created_by_professor-start_time)/60, zeros(size(created_by_professor, 1)), 'r.'); 
      hold on
%       h = plot((created_by_students-start_time)/60, zeros(size(created_by_students, 1)), 'k.'); 

   % h = plot(idea_creation_times(:,3) - start_time, zeros(size(idea_creation_times, 1)), 'k.');
    hold off
    meeting_topics(:, 4) = (meeting_topics(:, 4)-start_time)/60;
    for topic = meeting_topics'
        line([topic(4) topic(4)], [-1 1]);
        text(topic(4), 0, num2str(topic(1)));
    end
    
%     line([start_time start_time], [-1 1]);
%     line([stop_time stop_time], [-1 1]);

    i = i+1;
    
    set(gca, 'ytick', []);
    set(gca, 'ylim', [-1 1]);
    
    meeting_end = (stop_time-start_time)/60;
    
    h = line([meeting_end meeting_end], [-1 1]);
    set(h, 'Color', 'g');
    
    set(gca, 'xlim', [0 120]);
    set(h, 'MarkerSize', 16);
    hold off
    
end

xlabel('time since class started (min)');