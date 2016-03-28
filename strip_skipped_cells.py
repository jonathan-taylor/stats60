import nbformat
import sys

def strip_skipped_cells(input_nb_filename, output_nb_filename):
    nb = nbformat.read(input_nb_filename, as_version=4)

    for cell in nb.cells:
        if ('metadata' in cell and
            'slideshow' in cell['metadata'] and
            'slide_type' in cell['metadata']['slideshow']
            and cell['metadata']['slideshow']['slide_type'] == 'skip'):
            nb.cells.remove(cell)
    nbformat.write(nb, output_nb_filename)

if __name__ == "__main__":
    input_nb_filename = sys.argv[1]
    output_nb_filename = sys.argv[2]
    strip_skipped_cells(input_nb_filename, output_nb_filename)
