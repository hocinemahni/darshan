#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_File fh;
    MPI_Status st;

    const char *filename = "mpi_io_test.dat";

    /* Open (or create) the file collectively */
    int rc = MPI_File_open(MPI_COMM_WORLD, filename,
                           MPI_MODE_CREATE | MPI_MODE_WRONLY,
                           MPI_INFO_NULL, &fh);

    if (rc != MPI_SUCCESS) {
        if (rank == 0) {
            fprintf(stderr, "Error opening file %s\n", filename);
        }
        MPI_Abort(MPI_COMM_WORLD, rc);
    }

    /* Each rank writes a short message at a fixed offset */
    char buffer[128];
    int len = snprintf(buffer, sizeof(buffer),
                       "Hello from rank %d of %d\n", rank, size);

    MPI_Offset offset = (MPI_Offset)rank * 128;

    MPI_File_write_at(fh, offset, buffer, len, MPI_CHAR, &st);

    /* Ensure data is written */
    MPI_File_sync(fh);
    MPI_File_close(&fh);

    if (rank == 0) {
        printf("Wrote %d records to %s\n", size, filename);
    }

    MPI_Finalize();
    return 0;
}
