import logging
from contextlib import contextmanager
from functools import partial

from message_ix import Scenario
from message_ix.reporting import Key, Reporter, computations

log = logging.getLogger(__name__)

PLOTS = [
    ("activity", computations.stacked_bar, "out:nl-t-ya", "Mt"),
    ("capacity", computations.stacked_bar, "CAP:nl-t-ya", "Mt"),
    ("demand", computations.stacked_bar, "demand:n-c-y", "Mt"),
    ("extraction", computations.stacked_bar, "EXT:n-c-g-y", "Mt"),
    ("new capacity", computations.stacked_bar, "CAP_NEW:nl-t-yv", "t"),
    ("prices", computations.stacked_bar, "PRICE_COMMODITY:n-c-y", "￥/t"),
]


def prepare_plots(rep: Reporter, input_costs="￥/t") -> None:
    """Prepare `rep` to generate plots for tutorial energy models.

    Makes available several keys:

    - ``plot activity``
    - ``plot demand``
    - ``plot extraction``
    - ``plot fossil supply curve``
    - ``plot capacity``
    - ``plot new capacity``
    - ``plot prices``

    To control the contents of each plot, use :meth:`.set_filters` on `rep`.
    """
    # Conversion factors between input units and plotting units
    # TODO use exact units in all tutorials
    # TODO allow the correct units to pass through reporting
    cost_unit_conv = {
        "￥/t": 1.0,
        "￥/Mt": 1e3,
        "￥/kt": 1e6,
    }.get(input_costs, 1.0)

    # Basic setup of the reporter
    rep.configure(units={"replace": {"-": ""}})

    # Add one node to the reporter for each plot
    for title, func, key_str, units in PLOTS:
        # Convert the string to a Key object so as to reference its .dims
        key = Key.from_str_or_key(key_str)

        # Operation for the reporter
        comp = partial(
            # The function to use, e.g. stacked_bar()
            func,
            # Other keyword arguments to the plotting function
            dims=key.dims,
            units=units,
            title=f"Liquid Fuel Supply System {title.title()}",
            cf=1.0 if title != "prices" else (cost_unit_conv * 100 / 8760),
            stacked=title != "prices",
        )

        # Add the computation under a key like "plot activity"
        rep.add(f"plot {title}", (comp, key))

    rep.add(
        "plot fossil supply curve",
        (
            partial(
                computations.plot_cumulative,
                labels=("Fossil supply", "Resource volume", "Cost"),
            ),
            "resource_volume:n-g",
            "resource_cost:n-g-y",
        ),
    )


@contextmanager
def solve_modified(base: Scenario, new_name: str):
    """Context manager for a cloned scenario.

    At the end of the block, the modified Scenario yielded by :func:`solve_modified` is
    committed, set as default, and solved. Use in a ``with:`` statement to make small
    modifications and leave a variable in the current scope with the solved scenario.

    Examples
    --------
    >>> with solve_modified(base_scen, "new name") as s:
    ...     s.add_par( ... )  # Modify the scenario
    ...     # `s` is solved at the end of the block

    Yields
    ------
    .Scenario
        Cloned from `base`, with the scenario name `new_name` and no solution.
    """
    s = base.clone(
        scenario=new_name,
        annotation=f"Cloned by solve_modified() from {repr(base.scenario)}",
        keep_solution=False,
    )
    s.check_out()

    yield s

    s.commit("Commit by solve_modified() at end of 'with:' statement")
    s.set_as_default()
    s.solve()
