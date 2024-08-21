package org.mycore.mir.migration;

import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.servlet.ServletContext;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.events.MCRStartupHandler.AutoExecutable;
import org.mycore.services.queuedjob.MCRJob;
import org.mycore.services.queuedjob.MCRJobQueue;
import org.mycore.services.queuedjob.MCRJobQueueManager;
import org.mycore.services.queuedjob.MCRJobStatus;
import org.mycore.services.queuedjob.MCRJob_;
import org.mycore.util.concurrent.MCRTransactionableRunnable;

import java.util.ArrayList;
import java.util.List;

/**
 * Class creates {@link MCRJob} in {@link MCRJobQueue} that migrates all static history content.
 *
 * @author shermann (Silvio Hermann)
 * */
public class MIRMigrateStaticHistoryContent implements AutoExecutable {

    @Override
    public String getName() {
        return MIRMigrateStaticHistoryContent.class.getName();
    }

    @Override
    public int getPriority() {
        return 0;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        MCRTransactionableRunnable runnable = new MCRTransactionableRunnable(() -> {
            if (!alreadyDone()) {
                MCRJobQueueManager
                    .getInstance()
                    .getJobQueue(MIRMigrateStaticHistoryContentJobAction.class)
                    .offer(new MCRJob(MIRMigrateStaticHistoryContentJobAction.class));
            }
        });
        new Thread(runnable).start();
    }

    private boolean alreadyDone() {
        EntityManager manager = MCREntityManagerProvider.getCurrentEntityManager();
        CriteriaBuilder builder = manager.getCriteriaBuilder();
        CriteriaQuery<MCRJob> criteria = builder.createQuery(MCRJob.class);
        Root<MCRJob> root = criteria.from(MCRJob.class);

        List<Predicate> predicates = new ArrayList<Predicate>();
        predicates.add(builder.equal(root.get(MCRJob_.action), MIRMigrateStaticHistoryContentJobAction.class));
        predicates.add(builder.equal(root.get(MCRJob_.status), MCRJobStatus.FINISHED));

        criteria.where(predicates.toArray(new Predicate[] {}));
        List<MCRJob> resultList = manager.createQuery(criteria).getResultList();

        return resultList.size() > 0;
    }
}
